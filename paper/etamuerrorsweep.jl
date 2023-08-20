using Integrals
using Roots
using CairoMakie
using Foresight


_p(μ, η) = x -> x ≥ 0 ? exp(-(2/η^2)*(-(μ*x^2/2)+x^4/4)) : 0
_p̂(μ, η) = x -> x ≥ 0 ? exp(-(2/η^2)*(-(μ*x^2)/2)) : 0

function p(μ, η)
    f = _p(μ, η)
    A = solve(IntegralProblem((u, p) -> f(u), -Inf, Inf), QuadGKJL()) |> first
    return x -> f(x)/A
end

function p̂(μ, η)
    f = _p̂(μ, η)
    A = solve(IntegralProblem((u, p) -> f(u), -Inf, Inf), QuadGKJL()) |> first
    return x -> f(x)/A
end

_E(μ, η) = x -> p(μ, η)(x) - p̂(μ, η)(x)
function E(μ, η)
    f = x -> abs(_E(μ, η)(x))
    A = solve(IntegralProblem((u, p) -> f(u), -Inf, Inf), QuadGKJL()) |> first
    return A
end

# plot(-0.1:0.01:1, p(-0.1, 0.1))
# plot!(-0.1:0.01:1, p̂(-0.1, 0.1))
# current_figure()

# plot(-0.1:0.01:1, _E(-0.1, 0.1))

# * Heatmap over mu, x
# heatmap(-0.1:0.01:1, -1:0.01:-0.01, (x, μ) -> _E(μ, 0.1)(x))



# * Error in the density estimate
function m(f, l=-Inf, u=Inf)
    return m = solve(IntegralProblem((u, p) -> u*f(u), l, u), QuadGKJL()) |> first
end

function σ(f, l=-Inf, u=Inf)
    _m = m(f, l, u)
    v = solve(IntegralProblem((u, p) -> (u-_m)^2*f(u), l, u), QuadGKJL()) |> first
    return sqrt(v)
end

function _med(f)
    # A = solve(IntegralProblem((u, p) -> f(u), -Inf, Inf), QuadGKJL()) |> first
    g(x) = solve(IntegralProblem((u, p) -> f(u), -Inf, x), QuadGKJL()) |> first
    return g
end
med(f) = fzero(x->_med(f)(x)-0.5, 1)

function _Δ(f)
    m = med(f)
    return 1/σ(f, m, Inf) - 1/σ(f, -Inf, m)
end

function Δ(μ, η)
    for N = 1:500
        try
            μ = μ + 1e-3*randn()*μ
            η = η + 1e-3*randn()*η
            a = abs(_Δ(p(μ, η)) - _Δ(p̂(μ, η)))
            if !isinf(a) && !isnan(a) && a < 1e3
                return a
            end
        catch e
            continue
        end
    end
    return NaN
end


f = Figure(; resolution=(900, 360));
ax1 = Axis(f[1, 1]; xlabel="μ", ylabel="η", title="Invariant density", aspect=1)
ax2 = Axis(f[1, 3]; xlabel="μ", ylabel="η", title="RAD factor", aspect=1)
# * Heatmap over mu, eta for density error
p1 = heatmap!(ax1, -1:0.01:-0.01, 0.05:0.01:1, (μ, η) -> E(μ, η))
Colorbar(f[1, 2], p1, label="Error")

# * Heatmap over mu, eta for RAD distribution factor error
p2 = heatmap!(ax2, -1:0.01:-0.01, 0.05:0.01:1, Δ)
Colorbar(f[1, 4], p2, label="Error")
Label(f[1, 1, TopLeft()], "(A)")
Label(f[1, 3, TopLeft()], "(B)")
colgap!(f.layout, 1, 0.1)
colgap!(f.layout, 3, 0.1)
