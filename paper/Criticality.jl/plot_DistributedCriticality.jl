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

Random.seed!(32)
nulls = 1e6
colors = [Makie.colorant"#D95319", Makie.colorant"#0072BD", Makie.colorant"black"]
file = jldopen("$(@__DIR__)/Data/criticality.jld2")
sessions = keys(file)
badsessions = [s for s in sessions if isnothing(file[s])]
goodsessions = setdiff(sessions, badsessions)
session_table = read("$(@__DIR__)/Data/session_table.json", String) |> JSON.parse |> DataFrame
oursessions = session_table.ecephys_session_id
goodsessions = intersect(goodsessions, string.(oursessions))
mice = session_table[string.(session_table.ecephys_session_id).∈[goodsessions], :mouse_id]
@info "We have $(length(goodsessions)) sessions across $(length(unique(mice))) mice"

compare(x, y; kwargs...) = HypothesisTests.pvalue(HypothesisTests.MannWhitneyUTest(x, y); kwargs...)
function formatrho(ρ)
    r = round(ρ, sigdigits=2)
    r = abs(r) ≥ 0.01 ? r : "$(Int(sign(r)*10))^{$(round(Int, log10(abs(r))))}"
end
function formatp(𝑝, nulls=NaN)
    if 𝑝 == 0.0
        p = "p\\, <\\, 10^{-$(floor(Int, log10(nulls)))}"
    else
        if 𝑝 < 0.01
            p = "p\\, <\\, 10^{$(ceil(Int, log10(𝑝)))}"
        else
            p = "p = $(round(𝑝, sigdigits=1))"
        end
    end
end

function pulldata(f; nulls=false)
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

    if nulls > 0 # Shuffle structures, keeping relative labelling of channels
        @info "Computing $(Int(nulls)) permutations for $f, be patient"
        xss = [collect.(f) for f in deepcopy(F)]
        p = Vector{Float64}(undef, Int(nulls))
        ρs_sur = Vector{Any}(undef, Int(nulls))
        Threads.@threads for i in eachindex(p)
            _xss = deepcopy(xss)
            for sesh in eachindex(_xss)
                is = randperm(length(_xss[sesh]))
                for struc in eachindex(_xss[sesh])
                    _xss[sesh][struc] .= is[struc]
                end
            end
            ρs_sur[i] = map(_xss, F) do xs, f
                corkendall(xs |> flatten |> collect, f |> flatten |> collect)
            end
            p[i] = corkendall(_xss |> flatten |> flatten |> collect, ys)
        end
        𝑝 = mean(abs(ρ) .< abs.(p))
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
    D = innerjoin(D, session_table[!, [:session, :experience_level, :equipment_name, :mouse_id, :sex, :is_wt]], on=:session)
    D = groupby(D, [:session, :structure, :experience_level, :equipment_name, :mouse_id, :sex, :is_wt])
    D = combine(D, :value => mean)
    D[!, :mouse_id] = string.(D.mouse_id)

    fm = @formula(value_mean ~ structure + (1 | mouse_id))
    a = anova(lme(fm, D); type=3)
    open(@__DIR__() * "/$f.anova", "w") do file
        write(file, sprint(show, a))
    end

    return (; f, F, F̄, structures, Ns, xs, ys, ρ, 𝑝, nulls, ρs, ρs_sur)
end

function criticality_plot!(ax, D; session=nothing, color=:hierarchy, shift=0.0, medians=true, kwargs...)
    f, F, structures, Ns, xs, ys, ρ, 𝑝, nulls, ρs, ρs_sur = getindex.([D], [:f, :F, :structures, :Ns, :xs, :ys, :ρ, :𝑝, :nulls, :ρs, :ρs_sur])

    if !isnothing(session) # Plot for a single mouse
        xs = deepcopy(F[session])
        [xs[i] .= i for i in eachindex(xs)]
        xs = xs |> flatten |> collect
        ys = F[session] |> flatten |> collect
        ρ = ρs[session]
        𝑝 = mean(abs(ρ) .< abs.(getindex.(ρs_sur, session)))
    end
    begin # * Plot the distribution of values over cortical regions
        colormap = cgrad(:inferno; alpha=0.4)
        colormap = getindex.([colormap], (xs) ./ (Ns + 1))
        strokecolor = Makie.RGB.(unique(colormap))
        if color != :hierarchy
            colormap = (color, 0.3)
            strokecolor = color
        end
        if nulls > 0
            ax.title = L"\tau = %$(formatrho(ρ))\,\, (%$(formatp(𝑝, nulls)))"
        else
            ax.title = L"\tau = %$(formatrho(ρ))"
        end
        ax.xlabel = "Structure"
        ax.ylabel = "$(f)"
        ax.xticks = (1:length(unique(xs)), structures)
        datalimits = x -> (mean(x) .- 3 * std(x), mean(x) .+ 3 * std(x))
        violin!(ax, xs .- shift, ys; color=colormap, strokecolor, strokewidth=3, show_median=true, datalimits, kwargs...)

        # Plot subject means
        if medians
            F̃ = [median(ys[xs.==i]) for i in 1:Ns]
            lines!(ax, (1:Ns) .- shift, F̃, color=(:black, 0.3)) # Connect subject means
            scatter!(ax, (1:Ns) .- shift, F̃, color=:black)
        end
    end
end

function criticality_boxplot!(ax, Ds; kwargs...)
    ρ = getindex.(Ds, :ρs)
    ρ_sur = getindex.(Ds, :ρs_sur) .|> flatten .|> collect

    Δ = 0.15
    hlines!(ax, [0], color=:black, linestyle=:dash, linewidth=2)
    @info "Sample size for boxplot data is n = $(length.(ρ)), or n = $(length.(ρ_sur)) for surrogates"

    for i in eachindex(ρ)
        boxplot!(ax, fill(i, length(ρ_sur[i])) .- Δ, (ρ_sur[i]); color=(colors[i], 0.3), strokecolor=colors[i], outliercolor=(colors[i], 0.5), width=0.25, show_outliers=false, strokestyle=:dash, kwargs...)
        boxplot!(ax, fill(i, length(ρ[i])) .+ Δ, (ρ[i]); color=(colors[i], 0.3), strokecolor=colors[i], outliercolor=colors[i], width=0.25, show_outliers=true, kwargs...)
    end

    rangebars!(ax, [0.45], [1 - Δ], [1 + Δ], direction=:x, whiskerwidth=10, color=:black)
    rangebars!(ax, [0.55], [2 - Δ], [2 + Δ], direction=:x, whiskerwidth=10, color=:black)
    rangebars!(ax, [0.8], [3 - Δ], [3 + Δ], direction=:x, whiskerwidth=10, color=:black)

    tail = :both
    p0 = compare(ρ[1], ρ_sur[1]; tail)
    p1 = compare(ρ[2], ρ_sur[2]; tail)
    p2 = compare(ρ[3], ρ_sur[3]; tail)
    text!(ax, [1], [0.5]; text=L"%$(formatp(p0))", fontsize=12, align=(:center, :bottom))
    text!(ax, [2], [0.6]; text=L"%$(formatp(p1))", fontsize=12, align=(:center, :bottom))
    t = text!(ax, [2.55], [0.75]; text=L"%$(formatp(p2))", fontsize=12, align=(:center, :center))
    translate!(t, Vec3f(0, 0, 1000))
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
    f = Figure(size=(720, 420))
    features = [:DN_Spread_Std, :AC_1, :CR_RAD]
    Ds = pulldata.(features; nulls)
    session = 16
    axargs = (; xgridvisible=false, ygridvisible=false, xminorticksvisible=false, xminorticks=IntervalsBetween(5), yminorticksvisible=true, yminorticks=IntervalsBetween(5), xtickalign=1, ytickalign=1, xminortickalign=1, yminortickalign=1)

    ax1 = Axis(f[2, 1]; limits=((nothing, nothing), (-0.85, 1.0)), ylabel=L"\tau", ylabelsize=18, axargs...)
    ax1.xticks = (1:length(features), string.(features))

    criticality_boxplot!(ax1, Ds; strokewidth=3, whiskerwidth=0.2)

    gl = f[1, 2][1:2, 1:2] = GridLayout()
    ax2 = Axis(gl[1:2, 1]; axargs...)
    ax2.xticklabelrotation = π / 6
    criticality_plot!(ax2, Ds[3]; session)
    ax2.limits = ((nothing, nothing), (-1.75, -0.1))
    ax2.xlabelvisible = false

    # * Inset SD and AC
    ax = Axis(gl[1, 2]; axargs..., yticklabelsvisible=false, ylabelvisible=false)
    ax.xlabelvisible = ax.xticklabelsvisible = false
    hideydecorations!(ax)
    ax.ylabelvisible = true
    ax.ylabelsize = 9
    ax.yaxisposition = :right
    criticality_plot!(ax, Ds[1]; session, medians=false, color=colors[1], strokewidth=1)

    ax = Axis(gl[2, 2]; axargs...)
    ax.xticklabelsvisible = false
    hideydecorations!(ax)
    ax.ylabelvisible = true
    ax.ylabelsize = 9
    ax.yaxisposition = :right
    criticality_plot!(ax, Ds[2]; session, medians=false, color=colors[2], strokewidth=1)
    ax.xlabel[] = ax.title[]
    ax.title = ""

    colsize!(gl, 1, Relative(0.66))
    colgap!(gl, 1, Relative(0.01))
    rowgap!(gl, 1, Relative(0.05))



    gl = f[2, 2][1:2, 1:2] = GridLayout()
    ax2 = Axis(gl[1:2, :]; axargs...)
    criticality_plot!(ax2, Ds[3])
    ax2.limits = ((nothing, nothing), (-1.8, 0.2))
    ax2.xlabelvisible = false
    ax2.xticklabelrotation = π / 6
    # * Inset SD and AC
    ax = Axis(gl[1, 2]; axargs..., yticklabelsvisible=false, ylabelvisible=false)
    ax.xlabelvisible = ax.xticklabelsvisible = false
    hideydecorations!(ax)
    ax.ylabelvisible = true
    ax.ylabelsize = 9
    ax.yaxisposition = :right
    criticality_plot!(ax, Ds[1]; medians=false, color=colors[1], strokewidth=1)
    ax = Axis(gl[2, 2]; axargs...)
    ax.xticklabelsvisible = false
    hideydecorations!(ax)
    ax.ylabelvisible = true
    ax.ylabelsize = 9
    ax.yaxisposition = :right
    criticality_plot!(ax, Ds[2]; medians=false, color=colors[2], strokewidth=1)
    ax.xlabel[] = ax.title[]
    ax.title = ""

    colsize!(gl, 1, Relative(0.66))
    colgap!(gl, 1, Relative(0.01))
    rowgap!(gl, 1, Relative(0.05))

    Label(f[1, 1, TopLeft()], halign=:left, valign=:bottom, text="(a)", fontsize=22, font="Times")
    Label(f[1, 2, TopLeft()], halign=:left, valign=:bottom, text="(b)", fontsize=22, font="Times")
    Label(f[2, 1, TopLeft()], halign=:left, valign=:bottom, text="(c)", fontsize=22, font="Times")
    Label(f[2, 2, TopLeft()], halign=:left, valign=:bottom, text="(d)", fontsize=22, font="Times")


    display(f)
    save(joinpath(@__DIR__, "criticality_neuropixels.pdf"), f)
end

close(file)
