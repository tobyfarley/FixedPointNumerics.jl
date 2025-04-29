module FixedPointNumerics

export ==

include("FixedPoint.jl")
include("BigFixedPoint.jl")

function BigFixedPoint(z::FixedPoint)
    return BigFixedPoint(BigInt(z.value), z.precision)  
end

function eq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return eq(x,y)
end

function eq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return eq(x,y)
end

==(z::FixedPoint, w::BigFixedPoint) = eq(z,w)

==(z::BigFixedPoint, w::FixedPoint) = eq(z,w)

end