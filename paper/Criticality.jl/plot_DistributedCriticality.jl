using CairoMakie
using DimensionalData
using Random
using StatsBase
using HypothesisTests
using AnovaMixedModels
using JSON
using DataFrames
using JLD2
using Catch22
using TimeseriesTools
import Base.Iterators.flatten
import CairoMakie.RGB

file = jldopen("$(@__DIR__)/Data/criticality.jld2")
sessions = keys(file)
badsessions = [s for s in sessions if isnothing(file[s])]
goodsessions = setdiff(sessions, badsessions)
session_table = read("$(@__DIR__)/Data/session_table.json", String) |> JSON.parse |> DataFrame
oursessions = session_table.ecephys_session_id
goodsessions = intersect(goodsessions, string.(oursessions))
mice = session_table[string.(session_table.ecephys_session_id).∈[goodsessions], :mouse_id]
@info "We have $(length(goodsessions)) sessions across $(length(unique(mice))) mice"

ttest(x, y; kwargs...) = HypothesisTests.pvalue(HypothesisTests.OneSampleTTest(x, y); kwargs...)
function lighten(c, a)
    c = parse(RGB, c)
    c = [(1 - a) + a * c.r, (1 - a) + a * c.g, (1 - a) + a * c.b]
    return RGB(c...)
end

function pulldata(f; pvalue=false)
    F = [[F[f, :] for F in file[s]] for s in goodsessions]
    structures = [f.metadata[:structure] for f in file[first(sessions)]]
    Ns = length(structures)
    F̄ = [mean.(f) for f in F] # Mean over channels

    # * Correlation and p value
    xs = deepcopy(F)
    [[xs[i][j] .= j for j in eachindex(xs[i])] for i in eachindex(xs)] # Hierarchy ranks
    xs = xs |> flatten |> flatten |> collect
    ys = F |> flatten |> flatten |> collect
    ρ = corkendall(xs, ys) # Group-level correlation

    ρs = map(F) do f # Individual subject correlations
        _xs = [fill(i, length(f[i])) for i in eachindex(f)] |> flatten |> collect
        _ys = f |> flatten |> collect
        corkendall(_xs, _ys)
    end

    if pvalue > 0 # Shuffle structures, keeping relative labelling of channels
        @info "Computing $(Int(pvalue)) permutations for $f, be patient"
        xss = [collect.(f) for f in deepcopy(F)]
        p = Vector{Float64}(undef, Int(pvalue))
        ρs_sur = Vector{Any}(undef, Int(pvalue))
        Threads.@threads for i in eachindex(p)
            _xss = deepcopy(xss)
            for sesh in eachindex(_xss)
                is = randperm(length(_xss[sesh]))
                for struc in eachindex(_xss[sesh])
                    _xss[sesh][struc] .= is[struc]
                end
            end
            ρs_sur[i] = map(_xss, F) do xs, f
                _xs = xs |> flatten |> collect
                _ys = f |> flatten |> collect
                corkendall(_xs, _ys)
            end
            p[i] = corkendall(_xss |> flatten |> flatten |> collect, ys)
        end
        𝑝 = mean(ρ .< p)
    else
        𝑝 = NaN
        ρs_sur = []
    end

    # * Little anova
    D = map(F) do f
        d = map(f) do _f
            d = DataFrame(_f)
            d[!, :structure] .= DimensionalData.metadata(_f)[:structure]
            d[!, :session] .= DimensionalData.metadata(_f)[:sessionid]
            return d
        end
        vcat(d...)
    end
    D = vcat(D...)

    session_table[!, :session] = session_table.ecephys_session_id
    D = innerjoin(D, session_table[!, [:session, :experience_level, :equipment_name, :mouse_id]], on=:session)
    D = groupby(D, [:session, :structure, :experience_level, :equipment_name, :mouse_id])
    D = combine(D, :value => mean)
    D[!, :experience_level] = string.(D.experience_level)
    D[!, :equipment_name] = string.(D.equipment_name)
    D[!, :session] = string.(D.session)
    D[!, :mouse_id] = string.(D.mouse_id)

    fm = @formula(value_mean ~ structure * experience_level * equipment_name + (1 | mouse_id / session))
    a = anova(lme(fm, D); type=3)
    open(@__DIR__() * "/$f.anova", "w") do file
        write(file, sprint(show, a))
    end

    return (; f, F, F̄, structures, Ns, xs, ys, ρ, 𝑝, pvalue, ρs, ρs_sur)
end

function criticality_plot!(ax, D)
    f, structures, Ns, xs, ys, ρ, 𝑝, pvalue = getindex.([D], [:f, :structures, :Ns, :xs, :ys, :ρ, :𝑝, :pvalue])
    begin # * Plot the distribution of values over cortical regions
        colormap = getindex.([cgrad(:inferno; alpha=0.4)], (xs) ./ (Ns + 1))
        if pvalue > 0
            if 𝑝 == 0.0
                ax.title = L"\tau = %$(round(ρ, sigdigits=2)),\,  p\, <\, 10^{-%$(floor(Int, log10(pvalue)))}"
            else
                ax.title = L"\tau = %$(round(ρ, sigdigits=2)),\,  p = %$(round(𝑝, sigdigits=2))"
            end
        else
            ax.title = L"\tau = %$(round(ρ, sigdigits=2)); "
        end
        ax.xlabel = "Structure"
        ax.ylabel = "$(f)"
        ax.xticks = (1:length(unique(xs)), structures)
        datalimits = x -> (mean(x) .- 3 * std(x), mean(x) .+ 3 * std(x))
        violin!(ax, xs, ys; color=colormap, strokecolor=Makie.RGB.(unique(colormap)), strokewidth=3, show_median=true, datalimits)

        # Plot subject means
        F̃ = [median(ys[xs.==i]) for i in 1:Ns]
        lines!(ax, 1:Ns, F̃, color=(:black, 0.3)) # Connect subject means
        scatter!(ax, 1:Ns, F̃, color=:black)
    end
end

function criticality_boxplot!(ax, Ds; kwargs...)
    ρ = getindex.(Ds, :ρs)
    ρ_sur = getindex.(Ds, :ρs_sur) |> flatten |> collect

    Δ = 0.15
    hlines!(ax, [0], color=:black, linestyle=:dash, linewidth=2)

    colors = [Makie.colorant"#D95319", Makie.colorant"#0072BD", Makie.colorant"black"]
    for i in eachindex(ρ)
        boxplot!(ax, fill(i, length(ρ_sur[i])) .- Δ, (ρ_sur[i]); color=lighten(colors[i], 0.3), strokecolor=colors[i], outliercolor=(colors[i], 0.5), width=0.25, show_outliers=false, kwargs...)
        boxplot!(ax, fill(i, length(ρ[i])) .+ Δ, (ρ[i]); color=lighten(colors[i], 0.3), strokecolor=colors[i], outliercolor=colors[i], width=0.25, show_outliers=false, kwargs...)
    end

    rangebars!(ax, [0.45], [1 - Δ], [1 + Δ], direction=:x, whiskerwidth=10, color=:black)
    rangebars!(ax, [0.55], [2 - Δ], [2 + Δ], direction=:x, whiskerwidth=10, color=:black)
    rangebars!(ax, [0.8], [3 - Δ], [3 + Δ], direction=:x, whiskerwidth=10, color=:black)

    tail = :both
    p0 = ttest(ρ[1], ρ_sur[1]; tail)
    p1 = ttest(ρ[2], ρ_sur[2]; tail)
    p2 = ttest(ρ[3], ρ_sur[3]; tail)
    text!(ax, [1], [0.5]; text="𝑝 = $(round(p0, sigdigits=2))", fontsize=16, align=(:center, :bottom))
    text!(ax, [2], [0.6]; text="𝑝 = $(round(p1, sigdigits=2))", fontsize=16, align=(:center, :bottom))
    text!(ax, [3], [0.85]; text="𝑝 = $(round(p2, sigdigits=2))", fontsize=16, align=(:center, :bottom))

    # lines!.([ax], [1:length(features)], collect.(zip(ρ...)), color=(:black, 0.2)) #    Connect subject medians
    # scatter!.([ax], [1:length(features)], collect.(zip(ρ...)),
    #     color=:black) # Connect subject means
end

if false # * All catch22 features
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
    Ds = pulldata.(features; pvalue=1e6)

    ax1 = Axis(f[1, 1], limits=((nothing, nothing), (-0.4, 1)), ylabel=L"τ", xgridvisible=false, ygridvisible=false, xminorticksvisible=false, xminorticks=IntervalsBetween(5), yminorticksvisible=true, yminorticks=IntervalsBetween(5), xtickalign=1, ytickalign=1, xminortickalign=1, yminortickalign=1)
    ax1.xticks = (1:length(features), string.(features))

    criticality_boxplot!(ax1, Ds; strokewidth=3, whiskerwidth=0.2)

    for i = reverse(eachindex(features))
        ax2 = Axis(f[i+1, 1]; xgridvisible=false, ygridvisible=false, xminorticksvisible=false, xminorticks=IntervalsBetween(5), yminorticksvisible=true, yminorticks=IntervalsBetween(5), xtickalign=1, ytickalign=1, xminortickalign=1, yminortickalign=1)
        criticality_plot!(ax2, Ds[i])

        if features[i] == :DN_Spread_Std
            ax2.ytickformat = x -> string.(round.(x .* 1e4, digits=1))
            Label(f[i+1, 1, Top()], halign=:left, "×10⁻⁴")
        end
    end
    display(f)
    save(joinpath(@__DIR__, "criticality_neuropixels.pdf"), f)
end

close(file)
