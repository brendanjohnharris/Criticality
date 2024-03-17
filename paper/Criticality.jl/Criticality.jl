#! /bin/bash
#=
exec julia -t auto --project=$HOME/code/Criticality/paper/Criticality.jl/ "${BASH_SOURCE[0]}" "$@"
=#
@info @__FILE__
@info pwd()
using CairoMakie
using DSP
using TimeseriesTools
using Foresight
import AllenNeuropixelsBase as AN
import TimeseriesTools.Operators.𝒯
using Catch22
set_theme!(foresight(:dark, :serif, :physics))

params = (;
    sessionid=1130113579, #1119946360, #1067588044, # 1128520325, #
    epoch=:longest,
    pass=(1, 20),
    stimulus="spontaneous",
    structures=["VISp", "VISl", "VISrl", "VISal", "VISpm", "VISam"]
)
session = AN.Session(params[:sessionid])


begin # * Get data
    LFP = map(params[:structures]) do structure
        AN.formatlfp(session; tol=6, params..., structure)
    end
end
begin # * Preprocess the theta oscillation
    x = bandpass.(LFP, [params[:pass]])
    y = map(x) do _x # Downsample
        ds = 10
        _x = _x[1:ds:end, :]
    end
    a = Catch22.DN_Spread_Std.(y)
    b = Catch22.AC[1].(y)
    c = Catch22.CR_RAD.(y)
end

begin # * Plot
    f = Figure(size=(480, 1080))

    r = a
    ax = Axis(f[1, 1], xticks=(1:length(r), params[:structures]), xticklabelrotation=π / 5,
        title="Standard deviation")
    [rainclouds!(ax, i .+ zeros(length(r[i])), r[i][:]) for i in 1:length(r)]

    r = b
    ax = Axis(f[2, 1], xticks=(1:length(r), params[:structures]), xticklabelrotation=π / 5,
        title="Autocorrelation")
    [rainclouds!(ax, i .+ zeros(length(r[i])), r[i][:]) for i in 1:length(r)]

    r = c
    ax = Axis(f[3, 1], xticks=(1:length(r), params[:structures]), xticklabelrotation=π / 5,
        title="RAD")
    [rainclouds!(ax, i .+ zeros(length(r[i])), r[i][:]) for i in 1:length(r)]

    display(f)
end
