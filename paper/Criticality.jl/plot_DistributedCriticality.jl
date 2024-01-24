using CairoMakie
using DimensionalData
using StatsBase
using JLD2
using Catch22
using TimeseriesTools

file = jldopen("$(@__DIR__)/Data/criticality.jld2")
sessions = keys(file)
badsessions = [s for s in sessions if isnothing(file[s])]
goodsessions = setdiff(sessions, badsessions)


function criticality_plot!(ax, f)
    begin # * Plot the median values of a given metric over visual cortical areas, across subjects
        F = map(goodsessions) do s
            map(file[s]) do F
                F[f, :]
            end
        end
        F̄ = map(F) do f # Median over channels
            median.(f)
        end
        structures = map(file[first(sessions)]) do f
            f.metadata[:structure]
        end
        Ns = length(structures)
    end

    begin
        xs = deepcopy(F)
        [[xs[i][j] .= j for j in eachindex(xs[i])] for i in eachindex(xs)]
        xs = vcat([vcat(vec.(x)...) for x in zip(xs...)]...)
        ys = vcat([vcat(vec.(x)...) for x in zip(F...)]...)
        ρ = cor(xs, tiedrank(ys))
        # xm = vcat((F̄ .|> axes .|> only .|> collect)...)
        # ym = vcat(F̄...)
        xm = 1:Ns
        ym = [median(ys[xs.==i]) for i in 1:Ns]
    end

    begin # * Plot the distribution of values over cortical regions
        colormap = getindex.([cgrad(:inferno; alpha=0.4)], (xs) ./ (Ns + 1))
        ax.title = L"\rho = %$(round(ρ, digits=2))"
        ax.xlabel = "Structure"
        ax.ylabel = "$(f)"
        ax.xticks = (1:length(unique(xs)), structures)
        violin!(ax, xs, ys; color=colormap, strokecolor=Makie.RGB.(unique(colormap)), strokewidth=3)

        # Plot subject medians
        lines!.([ax], F̄, color=(:black, 0.2)) # Connect subject medians
        scatter!.([ax], F̄, color=:black) # Connect subject medians
    end
end

begin # * RAD vs conventional features
    f = Figure(size=(480, 1080))
    features = [:DN_Spread_Std, :AC_1, :CR_RAD]
    axs = [Axis(f[i, 1]) for i in 1:length(features)]
    criticality_plot!.(axs, features)
    axs[1].ytickformat = x -> string.(round.(x .* 1e4, digits=1))
    Label(f[1, 1, Top()], halign=:left, "×10⁻⁴")
    display(f)
    save(joinpath(@__DIR__, "criticality.pdf"), f)
end

begin # * All catch22 features
    f = Figure(size=(480, 6080))
    features = getnames(catch22)
    axs = [Axis(f[i, 1]) for i in 1:length(features)]
    criticality_plot!.(axs, features)
    display(f)
    save(joinpath(@__DIR__, "criticality22.pdf"), f)
end
