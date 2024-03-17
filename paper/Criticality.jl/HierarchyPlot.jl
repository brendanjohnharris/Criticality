#! /bin/bash
#=
scr="${BASH_SOURCE[0]}"
dir=`dirname $scr`
exec julia -t auto --project=$dir "${BASH_SOURCE[0]}" "$@"
=#
using CairoMakie
using GraphMakie
using GraphMakie.Graphs
using SimpleWeightedGraphs
using Downloads
using LinearAlgebra
using FileIO

## This file follows the code from Siegle et al. 2021: 'Survey of spiking in the mouse visual cortex reveals functional hierarchy'
# ? See https://github.com/AllenInstitute/neuropixels_platform_paper/blob/master/Figure2/comparison_anatomical_functional_connectivity_final.ipynb

## * The anatomical hierarchy
thr = 8
areas = ["VISp", "VISl", "VISrl", "VISal", "VISpm", "VISam"]
ascore = [-0.357, -0.093, -0.059, 0.152, 0.327, 0.441]
amatrix = [abs(a - b) for (a, b) in Iterators.product(values(ascore), values(ascore))] |> Symmetric
amatrix = amatrix ./ maximum(amatrix)
amatrix = 1.0 .- amatrix
amatrix = amatrix .- Diagonal(amatrix)
while sum(amatrix .> 0) > thr * 2
    amatrix[findmin(x -> x == 0 ? Inf : x, amatrix)[2]] = 0
end
amatrix = amatrix .- minimum(filter(>(0), amatrix)) / 1.25
amatrix = amatrix ./ maximum(amatrix)
ag = SimpleWeightedGraph(amatrix)

## * Load functional data
dir = tempdir()
baseurl = "https://github.com/AllenInstitute/neuropixels_platform_paper/raw/master/data/processed_data"
f = "FFscore_grating_10.npy"
Downloads.download(joinpath(baseurl, f), joinpath(dir, f))


## * Load functional data
FF_score, FF_score_b, FF_score_std = eachslice(load(joinpath(dir, f)), dims=1)
fmatrix = Symmetric((FF_score .+ FF_score') ./ 2)
fmatrix = abs.(fmatrix)
fmatrix = fmatrix ./ maximum(fmatrix)
fmatrix = 1.0 .- fmatrix
fmatrix = fmatrix .- Diagonal(fmatrix)
while sum(fmatrix .> 0) > thr * 2
    fmatrix[findmin(x -> x == 0 ? Inf : x, fmatrix)[2]] = 0
end
fmatrix = fmatrix .- minimum(filter(>(0), fmatrix)) / 1.25
fmatrix = fmatrix ./ maximum(fmatrix)
fg = SimpleWeightedGraph(fmatrix)


function offset(x, y, p)
    d = norm(x - y)
    x = (x + y) ./ 2
    u = reverse(x - y) |> collect
    u[1] = -u[1]
    u = u ./ norm(u)
    x = x .+ u .* p .* d
end

## * Plot the hierarchy
begin
    colormap = getindex.([cgrad(:inferno)], (1:6) ./ (7))
    img = load(joinpath(@__DIR__, "Vcortex.png"))
    layout = Point2f[
        (350, 350), # VISp
        (170, 310), # VISl
        (300, 130), # VISrl
        (180, 195), # VISal
        (475, 240), # VISpm
        (450, 140)] # VISam
    fwaypoints = Dict(
        1 => [offset(layout[2], layout[3], 0.4)],
        2 => [offset(layout[4], layout[3], 0.1)],
        6 => [offset(layout[4], layout[6], 0.3)],
        3 => [offset(layout[1], layout[5], -0.1)],
        4 => [offset(layout[4], layout[5], -0.1)],
    )


    fig = Figure(size=(400, 400))
    ax = Axis(fig[1, 1]; yreversed=true, aspect=1)
    image!(ax, img', alpha=0.5)
    # graphplot!(ax, fg;
    #     edge_width=weight.(edges(fg)) .* 5,
    #     selfedge_size=0,
    #     layout,
    #     edge_plottype=:beziersegments,
    #     curve_distance=20,
    #     curve_distance_usage=true,
    #     node_size=0,
    #     # waypoints=fwaypoints,
    #     edge_color=(colorant"#D95319", 0.7))
    p = graphplot!(ax, ag;
        edge_width=weight.(edges(ag)) .* 5,
        selfedge_size=0,
        layout,
        edge_plottype=:beziersegments,
        curve_distance=20,
        curve_distance_usage=true,
        node_size=30,
        ilabels=areas,
        ilabels_fontsize=9,
        node_color=colormap,
        # waypoints=fwaypoints,
        edge_color=(colorant"#0072BD", 0.7))
    Colorbar(fig[1, 2]; colormap=cgrad(colormap, categorical=true), label="Hierarchy rank", limits=(0.5, 6.5), ticks=1:6)
    display(fig)
    save(joinpath(@__DIR__, "hierarchy_plot.pdf"), fig)
end
