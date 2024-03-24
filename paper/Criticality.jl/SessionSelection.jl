#! /bin/bash
#=
exec julia -t auto --project=$HOME/code/Criticality/paper/Criticality.jl/ "${BASH_SOURCE[0]}" "$@"
=#

using DataFrames, Statistics, JLD2, JSON
import AllenNeuropixelsBase as AN
using AllenNeuropixelsBase.PythonCall
session_table = AN.VisualBehavior.getsessiontable()
probes = AN.VisualBehavior.getprobes()

function numprobes(sessionid)
    session_table[session_table[!, :ecephys_session_id].==sessionid, :probe_count][1]
end
targets = ["VISp", "VISl", "VISal", "VISrl", "VISpm", "VISam"]
function targetintersections(sessionid)
    structures = session_table[session_table.ecephys_session_id.==sessionid,
        :structure_acronyms][1]
    targetsintersected = [x ∈ structures for x in targets]
    targetsnotintersected = [x ∉ structures for x in targets]
    @debug "Targets not intersected: $(targets[targetsnotintersected])"
    return mean(targetsintersected)
end;

blacklist = [] # Cannot identify surface position (probe probably inserted too deep)

nonan = x -> sum(.!isnan.(x)) ./ length(x)

probetarget(X) = [(x == X) ? x : nothing for x in targets]

function has_target_location(x, y)
    idxs = y .∈ (targets,)
    return nonan(x[idxs])
end

function has_target_lfp(x, y)
    idxs = y .∈ (targets,)
    return all(x[idxs])
end

function probe_has_lfp(probeid)
    "True" == probes[probes.ecephys_probe_id.==probeid, :].has_lfp_data |> only
end

probes_with_lfp(probeids) = sum(probe_has_lfp.(probeids))

function minimum_target_units(y,
    targets=["VISp", "VISl", "VISal", "VISrl", "VISpm",
        "VISam"])
    idxs = [y .== t for t in targets]
    return minimum(sum.(idxs))
end

function skipnan(x)
    return x[.!isnan.(x)]
end

metrics = AN.VisualBehavior.getunitanalysismetrics()

session_metrics = DataFrames.combine(groupby(metrics, :ecephys_session_id),
    :ecephys_session_id => numprobes ∘ unique => :num_probes,
    :ecephys_session_id => targetintersections ∘ unique => :target_intersections,
    :ecephys_probe_id => (probes_with_lfp ∘ unique) => :probes_with_lfp,
    :genotype => (x -> all(isequal.(x, ("wt/wt",)))) => :is_wt,
    :abnormal_histology => unique => :abnormal_histology,
    :abnormal_activity => unique => :abnormal_activity,
    :experience_level => unique => :experience_level,
    :session_number => unique => :session_number,
    :prior_exposures_to_omissions => unique => :prior_exposures_to_omissions,
    :prior_exposures_to_image_set => unique => :prior_exposures_to_image_set,
    :dorsal_ventral_ccf_coordinate => nonan => :has_location,
    [:dorsal_ventral_ccf_coordinate, :structure_acronym] => has_target_location => :has_target_location,
    :max_drift => median ∘ skipnan,
    :presence_ratio => median ∘ skipnan,
    :isi_violations => median ∘ skipnan,
    :d_prime => median ∘ skipnan,
    :isolation_distance => median ∘ skipnan,
    :silhouette_score => median ∘ skipnan,
    :quality => (x -> mean(x .== ["good"])) => :mean_quality,
    :structure_acronym => minimum_target_units => :minimum_target_units,
    :snr => median ∘ skipnan)

session_metrics = session_metrics[:,
    .!(names(session_metrics) .∈ [names(session_table)]).|(names(session_metrics).=="ecephys_session_id")]
session_metrics = innerjoin(session_table, session_metrics, on=:ecephys_session_id,
    makeunique=true)

oursessions = subset(session_metrics,
    :ecephys_session_id => ByRow(!∈(blacklist)),
    :target_intersections => ByRow(==(1)),
    :abnormal_histology => ByRow(isempty),
    :abnormal_activity => ByRow(isempty),
    # :session_number => ByRow(==(1)),
    # :prior_exposures_to_omissions => ByRow(==(0)),
    # :prior_exposures_to_image_set => ByRow(>(15)),
    # :experience_level => ByRow(==("Familiar")),
    # :max_drift_median_skipnan => ByRow(<(50)),
    # :isi_violations_median_skipnan => ByRow(<(0.20)),
    # :presence_ratio_median_skipnan => ByRow(>(0.95)),
    # :snr_median_skipnan => ByRow(>(2.25)),
    :probes_with_lfp => ByRow(==(6)),
    :has_target_location => ByRow(==(1)))
# :equipment_name => ByRow(==("NP.1")))

write("$(@__DIR__)/Data/session_table.json", JSON.json(oursessions))

# Read the dataframe as read("$(@__DIR__)/Data/session_table.json", String) |> JSON.parse |> DataFrame
