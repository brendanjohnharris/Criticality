#! /bin/bash
#=
exec julia -t auto --project=$HOME/code/DDC/AllenAttention.jl/ "${BASH_SOURCE[0]}" "$@"
=#
@info @__FILE__
@info pwd()
using StatsBase
using DSP
using TimeseriesTools
using TimeseriesFeatures
using Catch22
using DataFrames
using JLD2
using IntervalSets
using Normalization
using Distributed
using TimeseriesTools.Unitful
using Peaks
using JSON
using USydClusters
import AllenAttention as AA
import AllenNeuropixels as AN

plotpath = "$(@__DIR__)/data/"
outfile = joinpath(plotpath, "criticality.jld2")
if isfile(outfile)
    mv(outfile, joinpath(plotpath, "criticality.jld2.bak"))
end

function send_criticality(sessionid=1130113579, plotpath)
    params = (;
        sessionid,
        epoch=:longest,
        pass=(1, 20),
        stimulus="flash_250ms",
        structures=["VISp", "VISl", "VISal", "VISrl", "VISpm", "VISam"]
    )
    session = AN.Session(params[:sessionid])
    # 𝑓 = [Catch22.DN_Spread_Std, TimeseriesFeatures.AC[1], Catch22.CR_RAD] |> FeatureSet
    # 𝑓 = 𝑓 + catch22
    begin # * Get data
        LFP = map(params[:structures]) do structure
            try
                AN.formatlfp(session; tol=6, params..., structure)
            catch
                nothing
            end
        end
    end
    begin # * Preprocess the theta oscillation
        x = bandpass.(LFP, [params[:pass]])
        y = map(x) do _x # Downsample
            ds = 10
            _x = _x[1:ds:end, :]
        end
        F = 𝑓.(y)
    end
    save(plotpath * "/$s.jld2", "F", F)
end

# * Distribute
session_table = jldopen("$plotpath/session_table.jld2")["session_table"]
oursessions = session_table.ecephys_session_id
# USydClusters.Physics.addprocs(length(oursessions); ncpus=2, mem=16, walltime=96)
USydClusters.Physics.addprocs(1; ncpus=2, mem=16, walltime=96)

# begin
#     @everywhere using Distributed
#     @everywhere import AllenAttention as AA
#     @everywhere set_theme!(foresight(:physics, :serif)) # :dark, :transparent
# end
O = [(@spawnat workers()[i] send_criticality(s, plotpath)) for (i, s) in enumerate(oursessions) |> first] # Worker 1 is master
fetch.(O) # Wait for workers to finish

# * Collect
F = map(oursessions) do s
    f = jldopen("$plotpath/$s.jld2")["F"]
    string(s) => f
end
save(outfile, F...)

rmprocs.(workers())
