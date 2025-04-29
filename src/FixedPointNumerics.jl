module FixedPointNumerics

export ==

include("FixedPoint.jl")
include("BigFixedPoint.jl")

function BigFixedPoint(z::FixedPoint)
    return BigFixedPoint(BigInt(z.value), z.precision)  
end

==(z::FixedPoint, w::BigFixedPoint) = eq(scale(BigFixedPoint(z),w),w)

==(z::BigFixedPoint, w::FixedPoint) = eq(scale(BigFixedPoint(z),w),w)

end