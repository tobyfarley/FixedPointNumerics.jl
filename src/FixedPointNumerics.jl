module FixedPointNumerics

export ==

include("FixedPoint.jl")
include("BigFixedPoint.jl")

==(z::FixedPoint, w::BigFixedPoint) = function (z,w)
        (x,y) = scale(BigFixedPoint(BigInt(z.value),z.precision),w)
        return eq(x,y)
end

==(z::BigFixedPoint, w::FixedPoint) = function (z,w)
    (x,y) = scale(BigFixedPoint(BigInt(w.value),w.precision),z)
    return eq(x,y)
end

end