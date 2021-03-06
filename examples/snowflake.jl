using OdinSon
using AffineTransforms
using Distributions
import Base: *, \
# extend the algebra of AffineTransform to be more permissive, tform{fwd, inv}
# does type checking, sent a fix upstream, remove once new tagged version
*(a::AffineTransform, v::AbstractArray) = tformfwd(a, v)
\(a::AffineTransform, x::AbstractArray) = tforminv(a, x)
#TODO: implement a real function like Mathematica's ReflectionMatrix
tformreflect = AffineTransform([-1.0 0.0; 0.0 1.0], [0.0, 0.0])

# wow , \theta vs 0 is very hard to see in this font
const rots = map(Θ -> tformrotate(Θ), 0:π/3:(2π - π/3))

function snowflake(pt)
    #TODO: this will be slow do to column major order, which I could easily switch
    mapslices(x -> rots[1]*x, pts, 2)

    # to decode: Join[Map[ReflectionMatrix[{1, 0}].# &, #], #] &
    endline = vcat([0.0 0.0], pts)
    startline = mapslices(x->tformreflect*x, endline, 2)
    arg2 = vcat(startline, endline)

    # this recreates the Outer(#1 . #2&, rots, arg2, 1) call in mathematica
    ##TODO: out can contain an 2dim Array, so the size is not enforced. I would likely
    ## need to use FixedSizeArrays to do this perfectly
    out = Array{Array{Float64, 2}}(length(rots))
    for i = 1:length(rots)
        poly = zeros(2, size(arg2, 1))
        for j = 1:size(arg2, 1)
            poly[:, j] = rots[i] * arg2[j:j, :]'
        end
        out[i] = poly
    end
    ps = map(p->Polygon(p, style=Style(stroke=nothing, fill=NC"white", fill_opacity=0.5)), out)

    return Canvas(ps, style=Style(fill=NC"black"))
end

pts = rand(Uniform(-1, 1), (rand(3:9), 2))
flake = snowflake(pts)
OdinSon.render(flake)
