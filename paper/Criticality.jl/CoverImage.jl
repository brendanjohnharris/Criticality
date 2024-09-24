using LinearAlgebra
using TimeseriesTools
backgroundcolor = :transparent
try # * Use GLMakie if available, much faster
    using GLMakie # * e.g. you could have it installed in the base project
    @info "Using GLMakie"
    global backgroundcolor = :white
catch
    using CairoMakie
end
using Random

f = Figure(; size=(400, 600), backgroundcolor)
ax = Axis3(f[1, 1]; aspect=:data, backgroundcolor)
μ_ext = (-50, 20)
xscale = 13
x_ext = (-15, 15) .* xscale
radius = 5
hidedecorations!(ax)

# * Draw a series of potential functions
V(x, μ) = -μ .* (x ./ xscale) .^ 2 / 2 + (x ./ xscale) .^ 4 ./ 4
colormap = cgrad(:RdYlBu) |> reverse # , [0, μ_ext[2] / (μ_ext[2] - μ_ext[1]), 1]
μs = range(μ_ext..., step=0.1)
xs = range(x_ext..., step=0.1)
surf = V.([xs], μs)
surf = stack(surf)
cmat = repeat(colormap[eachindex(μs)./(length(μs))]', length(xs))
surface!(ax, xs, μs, surf, color=cmat)

μs = range(μ_ext..., step=10)
for (i, μ) in enumerate(μs)
    y = (V.(xs, μ))
    lines!(ax, xs, fill(μ, length(y)), y, color=(colormap[i./(length(μs))], 0.9), linewidth=4, joinstyle=:round, linecap=:round)
end

# * Add lines to basin minima
begin
    μs = range(μ_ext..., step=0.0005)
    x1 = similar(μs)
    x1 .= NaN
    x2 = deepcopy(x1)
    x3 = deepcopy(x1)
    x1[μs.≤0] .= 0
    x2[μs.>0] .= sqrt.(μs[μs.>0]) .* xscale
    x3[μs.>0] .= -sqrt.(μs[μs.>0]) .* xscale
    lines!(ax, x1, μs, V.(x1, μs), color=:black, linewidth=2, alpha=0.2, joinstyle=:round, linecap=:round)
    lines!(ax, x2, μs, V.(x2, μs), color=:black, linewidth=2, alpha=0.2, joinstyle=:round, linecap=:round)
    lines!(ax, x3, μs, V.(x3, μs), color=:black, linewidth=2, alpha=0.2, joinstyle=:round, linecap=:round)
end

function centeroffset(μ, x, z; radius=radius, x_scale=xscale)
    f_x(x, μ) = -μ * x / (x_scale^2) + x^3 / (x_scale^4)
    f_μ(x, μ) = -0.5 * (x / x_scale)^2
    g = [f_x(x, μ), f_μ(x, μ), -1]
    g = g ./ norm(g)
    p = (x, μ, z) .- radius .* g
    return p
end
function centeroffset(μ::AbstractVector, x::AbstractVector, z::AbstractVector; kwargs...)
    ps = centeroffset.(μ, x, z; kwargs...)
    x = first.(ps)
    μ = getindex.(ps, 2)
    z = last.(ps)
    return x, μ, z
end
# * Add ball and trajectory
function ball!(ax, μs, ηs; color=:black, μmax=last(μs))
    function traj(μs, ηs; x0=0.0)
        if ηs isa Number
            ηs = fill(ηs, length(μs))
        end
        dt = 1e-4
        x = similar(μs)
        x[1] = x0
        for i in 2:length(μs)
            r = x[i-1]
            x[i] = r + (μs[i] * (r) / xscale^2 - (r)^3 / xscale^4) * dt + xscale * ηs[i] * sqrt(dt) * randn() # * Fix for xscale
        end
        return x
    end
    if μs isa Number
        μs = range(μ_ext[1], μmax, step=0.01)
    end
    xs = traj(μs, ηs)
    xs = .-xs
    zs = V.(xs, μs)
    xs, μs, zs = centeroffset(μs, xs, zs)
    trajectory = Point3f.(xs, μs, zs)

    idxs = μs .≤ μmax
    xs = xs[idxs]
    μs = μs[idxs]
    zs = zs[idxs]
    line = Point3f.(xs, μs, zs) |> Observable
    lines!(ax, line, color=(color, 0.8), linewidth=2, joinstyle=:round, linecap=:round)

    x = xs[end]
    μ = μs[end]
    z = zs[end]

    ball = Point3f(x, μ, z) |> Observable

    meshscatter!(ax, ball, markersize=radius, color=color, shininess=10.0f0, specular=1)
    return (; ball, line, trajectory)
end

Random.seed!(83)
cmap = cgrad(:inferno)
nballs = 4
μmax = μ_ext[2] - 2
balls = [ball!(ax, 5, 1; color=cmap[1/(nballs+1)], μmax),
    ball!(ax, -15, 2; color=cmap[2/(nballs+1)], μmax),
    ball!(ax, -25, 3; color=cmap[3/(nballs+1)], μmax),
    ball!(ax, μ_ext[2] - 2, 14 / 4; color=cmap[4/(nballs+1)], μmax)]
ax.azimuth = π / 1.7
ax.elevation = π / 3
limits!(ax, (-100, 100), (nothing, nothing), (-50, 100))
hidespines!(ax)
tightlimits!(ax)
save(joinpath(@__DIR__, "CoverImage_potential.png"), f; px_per_unit=10)
f


begin # * Now an animated version
    map(balls) do ball # ? Reset positions
        ball[:ball][] = ball[:trajectory][1]
        ball[:line][] = ball[:trajectory][[1]]
    end
    ts = map(enumerate(balls)) do (i, b)
             t = eachindex(b[:trajectory])
             zip(t, fill(i, length(t))) |> collect
         end |> Iterators.flatten |> collect
    ts = ts[1:50:end]
    aztrack = range(π / 2 - π / 4, π / 2 + π / 4, length=ceil(Int, length(ts) / 2))
    aztrack = vcat(aztrack, reverse(aztrack))
    aztrack = aztrack[1:length(ts)]


    record(f, joinpath(@__DIR__, "CoverImage_potential.mp4"), enumerate(ts);
        framerate=32) do (i, (t, b))
        ball = balls[b]
        ball[:ball][] = ball[:trajectory][t] .+ Point3f(0, 0, 0.001)
        ball[:line][] = ball[:trajectory][1:t] .+ Point3f(0, 0, 0.001)
        ax.azimuth[] = aztrack[i]
    end
end
