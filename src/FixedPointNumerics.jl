module FixedPointNumerics

include("FixedPoint.jl")
include("BigFixedPoint.jl")

==(z::FixedPoint, w::BigFixedPoint) = function (z,w)
        (x,y) = scale(BigFixedPoint(BigInt(z.value),z.precision),w)
        return x==y
end

==(z::FixedPoint, w::BigFixedPoint) = function (z,w)
    (x,y) = scale(BigFixedPoint(BigInt(w.value),w.precision),z)
    return x==y
end

end