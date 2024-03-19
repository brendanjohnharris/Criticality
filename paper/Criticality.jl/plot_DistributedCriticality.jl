using CairoMakie
using DimensionalData
using Random
using StatsBase
using HypothesisTests
using JLD2
using Catch22
using TimeseriesTools

file = jldopen("$(@__DIR__)/Data/criticality.jld2")
sessions = keys(file)
badsessions = [s for s in sessions if isnothing(file[s])]
goodsessions = setdiff(sessions, badsessions)
ascore = [-0.357, -0.093, -0.059, 0.152, 0.327, 0.441]

function pulldata(f; pvalue=false)
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

        ρs = map(F) do f
            _xs = vcat([fill(i, length(f[i])) for i in 1:length(f)]...)
            _ys = vcat(collect.(f)...)
            ρ = corkendall(_xs, _ys)
        end

        ρ = corkendall(xs, ys)

        # Shuffle region labels for each subject, but keep relative labels from a given
        # subject
        if pvalue
            @info "Computing permutations for $f, be patient"
            xss = [collect.(f) for f in deepcopy(F)]
            p = Vector{Float64}(undef, Int(1e6))
            Threads.@threads for i in eachindex(p)
                _xss = deepcopy(xss)
                for j in eachindex(_xss)
                    is = randperm(length(_xss[j]))
                    for k in eachindex(_xss[j])
                        _xss[j][k] .= is[k]
                    end
                end
                p[i] = corkendall(vcat([vcat(x...) for x in zip(_xss...)]...), ys)
            end
            𝑝 = mean(ρ .< p)
        else
            𝑝 = NaN
        end

        xm = 1:Ns
        ym = [median(ys[xs.==i]) for i in 1:Ns]
    end
    return F, F̄, structures, Ns, xs, ys, ρ, 𝑝, ρs, xm, ym
end

function criticality_plot!(ax, f; pvalue=false)
    F, F̄, structures, Ns, xs, ys, ρ, 𝑝, ρs, xm, ym = pulldata(f; pvalue)
    begin # * Plot the distribution of values over cortical regions
        colormap = getindex.([cgrad(:inferno; alpha=0.4)], (xs) ./ (Ns + 1))
        ax.title = L"\tau = %$(round(ρ, digits=2)),\,  p = %$(round(𝑝, sigdigits=3))"
        ax.xlabel = "Structure"
        ax.ylabel = "$(f)"
        ax.xticks = (1:length(unique(xs)), structures)
        violin!(ax, xs, ys; color=colormap, strokecolor=Makie.RGB.(unique(colormap)), strokewidth=3)

        # Plot subject medians
        lines!.([ax], F̄, color=(:black, 0.2)) # Connect subject medians
        scatter!.([ax], F̄, color=:black) # Connect subject medians
    end
end

function criticality_boxplot!(ax, features; kwargs...)
    ρ = []
    for f in features
        F, F̄, structures, Ns, xs, ys, _, _, ρs, xm, ym = pulldata(f)
        push!(ρ, ρs)
    end

    colors = [Makie.colorant"#D95319", Makie.colorant"#0072BD", Makie.colorant"black"]
    xs = vcat([fill(i, length(ρ[i])) for i in 1:length(ρ)]...)
    for i in eachindex(ρ)
        boxplot!(ax, fill(i, length(ρ[i])), abs.(ρ[i]); color=(colors[i], 0.4), strokecolor=colors[i], outliercolor=colors[i], kwargs...)
    end

    rangebars!(ax, [0.65], [1], [2], direction=:x, whiskerwidth=10, color=:black)
    rangebars!(ax, [0.92], [2], [3], direction=:x, whiskerwidth=10, color=:black)

    tail = :left
    p1 = pvalue(HypothesisTests.OneSampleTTest(abs.(ρ[1]), abs.(ρ[2])); tail)
    p2 = pvalue(HypothesisTests.OneSampleTTest(abs.(ρ[2]), abs.(ρ[3])); tail)
    text!(ax, [1.5], [0.65]; text="𝑝 = $(round(p1, sigdigits=3))", fontsize=16, align=(:center, :bottom))
    text!(ax, [2.5], [0.92]; text="𝑝 = $(round(p2, sigdigits=3))", fontsize=16, align=(:center, :bottom))

    # lines!.([ax], [1:length(features)], collect.(zip(ρ...)), color=(:black, 0.2)) #
    # Connect subject medians scatter!.([ax], [1:length(features)], collect.(zip(ρ...)),
    # color=:black) # Connect subject medians
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

begin # * Paper figure
    f = Figure(size=(400, 1000))
    features = [:DN_Spread_Std, :AC_1, :CR_RAD]
    ax1 = Axis(f[1, 1], limits=((nothing, nothing), (0, 1)), ylabel=L"|τ|", xgridvisible=false, ygridvisible=false, xminorticksvisible=true, xminorticks=IntervalsBetween(5), yminorticksvisible=true, yminorticks=IntervalsBetween(5), xtickalign=1, ytickalign=1)
    ax1.xticks = (1:length(features), string.(features))


    criticality_boxplot!(ax1, features; strokewidth=3, whiskerwidth=0.2)

    for i = eachindex(features)
        ax2 = Axis(f[i+1, 1]; xgridvisible=false, ygridvisible=false, xminorticksvisible=true,
            xminorticks=IntervalsBetween(5), minorticksvisible=true, yminorticks=IntervalsBetween(5), xtickalign=1, ytickalign=2)
        criticality_plot!(ax2, features[i]; pvalue=true)
    end
    display(f)
    save(joinpath(@__DIR__, "criticality_neuropixels.pdf"), f)
end
