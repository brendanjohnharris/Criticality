#! /bin/bash
#=
exec julia -t auto --project=$HOME/code/Criticality/paper/Criticality.jl/ "${BASH_SOURCE[0]}" "$@"
=#
using IntervalSets
using FileIO
using JSON
using DataFrames
import AllenNeuropixelsBase as AN

session_table = read("$(@__DIR__)/Data/session_table.json", String) |> JSON.parse |> DataFrame
oursessions = session_table.ecephys_session_id

for s in oursessions
    @info "Loading session $s"
    session = AN.Session(s)
    probes = AN.getprobes(session)
    for probeid in probes.id
        @info "Loading probe $probeid" # Load a piece of data to ensure the files have downloaded
        try
            LFP = AN.getlfp(session, probeid; times=100 .. 110)
            LFP = []
            GC.gc()
        catch e
            @info "$s failed!"
        end
    end
end
