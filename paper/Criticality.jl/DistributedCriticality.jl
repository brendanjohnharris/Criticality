#! /bin/bash
#=
exec julia -t auto --project=$HOME/code/Criticality/paper/Criticality.jl/ "${BASH_SOURCE[0]}" "$@"
=#
ENV["ALLEN_NEUROPIXELS_OFFLINE"] = "true"
@info @__FILE__
@info pwd()
using StatsBase
using DSP
using TimeseriesTools
using Catch22
using DataFrames
using JLD2
using IntervalSets
using Normalization
using Distributed
using TimeseriesTools.Unitful
using JSON
using USydClusters
import AllenNeuropixelsBase as AN

plotpath = "$(@__DIR__)/Data"
outfile = joinpath(plotpath, "criticality.jld2")
if isfile(outfile)
    mv(outfile, joinpath(plotpath, "criticality.jld2.bak"), force=true)
end

# * Distribute
session_table = read(joinpath(plotpath, "session_table.json"), String) |> JSON.parse |> DataFrame
oursessions = session_table.ecephys_session_id
USydClusters.Physics.addprocs(42; ncpus=3, mem=10, walltime=96)

begin
    @everywhere ENV["ALLEN_NEUROPIXELS_OFFLINE"] = "true"
    @everywhere using Distributed
    @everywhere using JLD2
    @everywhere using DSP
    @everywhere using StatsBase
    @everywhere using TimeseriesTools
    @everywhere using Catch22
    @everywhere import AllenNeuropixelsBase as AN
    @everywhere function send_criticality(sessionid, plotpath=$plotpath)
        if isfile(joinpath(plotpath, "$sessionid.jld2"))
            f = jldopen(joinpath(plotpath, "$sessionid.jld2"), "r")
            if haskey(f, "F")
                return true
            end
        end
        params = (;
            sessionid,
            epoch=:longest,
            pass=(1, 20),
            stimulus="spontaneous", #"flash_250ms",
            structures=["VISp", "VISl", "VISrl", "VISal", "VISpm", "VISam"],
            inbrain=true
        )
        session = AN.Session(params[:sessionid])
        𝑓 = [Catch22.DN_Spread_Std, Catch22.AC[1], Catch22.CR_RAD] |> FeatureSet
        𝑓 = 𝑓 + catch22
        begin # * Get data
            LFP = map(params[:structures]) do structure
                try
                    AN.formatlfp(session; tol=6, params..., structure)
                catch e
                    @warn e
                    nothing
                end
            end
        end
        if !any(isnothing.(LFP))# * Preprocess the theta oscillation
            x = bandpass.(LFP, [params[:pass]])
            y = map(x) do _x # Downsample
                ds = 10
                _x = _x[1:ds:end, :]
            end
            F = 𝑓.(y)
            save("$plotpath/$(params[:sessionid]).jld2", "F", F)
        end
        @info "Calculation complete"
    end
end
O = pmap(send_criticality, oursessions)
fetch.(O) # Wait for workers to finish

# * Collect
F = map(oursessions) do s
    if isfile("$plotpath/$s.jld2")
        f = jldopen("$plotpath/$s.jld2")["F"]
        Symbol(s) => f
    else
        Symbol(s) => nothing
    end
end
jldsave(outfile; F...)

# rmprocs.(workers())
USydClusters.Physics.selfdestruct()
