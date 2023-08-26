using CairoMakie
using Statistics

N = 10000
l = 1
t = LinRange(0, 100, N+l)
x = sin.(t) + 0.05.*randn(N+1)
y = x[1+l:end]
x = x[1:end-l]

𝐱 = hcat(x, y)
x = @view 𝐱[:, 1]
y = @view 𝐱[:, 2]

hexbin(x, y, cellsize=0.02)

θ = π/4
R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
𝐱′ = 𝐱*R'
x′ = @view 𝐱′[:, 1]
y′ = @view 𝐱′[:, 2]
hexbin!(x′, y′, cellsize=0.02, colormap=:inferno)
display(current_figure())

rₓ = cor(x, y)
r̂ₓ = (var(y′) - var(x′))/(var(x′) + var(y′))
rₓ ≈ r̂ₓ

σ = std
@assert σ(x′)^2 |>≈(0.5*σ(x - y)^2; rtol=1e-4)
@assert σ(y′)^2 |>≈(2 * σ(x)^2 ;rtol=1e-2)
Δx = y .- x
r̂_x = (2σ(x)^2 - 0.5σ(Δx)^2)/(2σ(x)^2 + 0.5σ(Δx)^2)
rₓ ≈ r̂ₓ
