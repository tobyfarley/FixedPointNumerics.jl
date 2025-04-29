module FixedPointNumerics

export FixedPoint, BigFixedPoint, scale, AbstractFloat, BigFloat, convert, string
export ==, >=, <=, >, <, +, -, *, /, ^, ÷, \, %, √, ∛, ∜
export show, log, log10, log2, sqrt, exp, exp2, exp10
export sin, sind, cos, cosd, cosh, tan, tand
export cmp, sincos, sincosd, sincospi, asin, sec, secd, sech
export csc, cscd, csch, cot, cotd, coth, asec, asecd, asech
export acsc, acscd, ascsh, acot, acotd, acoth, asin, asind, asinh
export asin, asind, asinh, acos, acosd, acosh, atan, atand, atanh
export deg2rad, rad2deg, hypot, log1p, ldexp, modf, trunc
export ispow2, invmod
export round, parse, sign, copysign

include("FixedPoint.jl")
include("BigFixedPoint.jl")

function BigFixedPoint(z::FixedPoint)
    return BigFixedPoint(BigInt(z.value), z.precision)
end

function copysign(z::FixedPoint, w::BigFixedPoint)
    x = FixedPoint(z.value)
    if w.value >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function copysign(z::BigFixedPoint, w::FixedPoint)
    x = BigFixedPoint(z.value, z.precision)
    if w.value >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function eq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return eq(x, y)
end

function eq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return eq(x, y)
end

function neq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return neq(x, y)
end

function neq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return neq(x, y)
end

function gteq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return gteq(x, y)
end

function gteq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return gteq(x, y)
end

function lteq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return lteq(x, y)
end

function lteq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return lteq(x, y)
end

function gt(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return gt(x, y)
end

function gt(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return gt(x, y)
end

function lq(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return lq(x, y)
end

function lq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return lq(x, y)
end

function add(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return add(x, y)
end

function add(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return add(x, y)
end

function sub(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return sub(x, y)
end

function sub(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return sub(x, y)
end

function mul(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return eq(x, y)
end

function eq(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return mul(x, y)
end

function floatdiv(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return floatdiv(x, y)
end

function floatdiv(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return floatdiv(x, y)
end

function rem(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return rem(x, y)
end

function rem(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return rem(x, y)
end

function intdiv(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return intdiv(x, y)
end

function intdiv(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return intdiv(x, y)
end

function pwr(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return pwr(x, y)
end

function pwr(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return pwr(x, y)
end

function invdiv(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return invdiv(x, y)
end

function invdiv(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return invdiv(x, y)
end

function invmod(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return invmod(x, y)
end

function invmod(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return invmod(x, y)
end

function cmp(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return cmp(x, y)
end

function cmp(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return cmp(x, y)
end

function maxprecision(z::BigFixedPoint, w::FixedPoint)
    (x, y) = scale(z, BigFixedPoint(w))
    return max(x, y)
end

function maxprecision(z::FixedPoint, w::BigFixedPoint)
    (x, y) = scale(BigFixedPoint(z), w)
    return max(x, y)
end

(==)(z::BigFixedPoint, w::FixedPoint) = eq(z, w)
(==)(z::FixedPoint, w::BigFixedPoint) = eq(z, w)

(>=)(z::BigFixedPoint, w::BigFixedPoint) = gteq(z, w)
(>=)(z::FixedPoint, w::BigFixedPoint) = gteq(z, w)

(<=)(z::BigFixedPoint, w::BigFixedPoint) = lteq(z, w)
(<=)(z::FixedPoint, w::BigFixedPoint) = lteq(z, w)

(<)(z::BigFixedPoint, w::BigFixedPoint) = lt(z, w)
(<)(z::FixedPoint, w::BigFixedPoint) = lt(z, w)

(>)(z::BigFixedPoint, w::BigFixedPoint) = gt(z, w)
(>)(z::FixedPoint, w::BigFixedPoint) = gt(z, w)

(+)(z::BigFixedPoint, w::BigFixedPoint) = add(z, w)
(+)(z::FixedPoint, w::BigFixedPoint) = add(z, w)

(-)(z::BigFixedPoint, w::BigFixedPoint) = sub(z, w)
(-)(z::FixedPoint, w::BigFixedPoint) = sub(z, w)

(*)(z::BigFixedPoint, w::BigFixedPoint) = mul(z, w)
(*)(z::FixedPoint, w::BigFixedPoint) = mul(z, w)

(/)(z::BigFixedPoint, w::BigFixedPoint) = floatdiv(z, w)
(/)(z::FixedPoint, w::BigFixedPoint) = floatdiv(z, w)

(\)(z::BigFixedPoint, w::BigFixedPoint) = invdiv(z, w)
(\)(z::FixedPoint, w::BigFixedPoint) = invdiv(z, w)

(^)(z::BigFixedPoint, w::BigFixedPoint) = pwr(z, w)
(^)(z::FixedPoint, w::BigFixedPoint) = pwr(z, w)

(÷)(z::BigFixedPoint, w::BigFixedPoint) = intdiv(z, w)
(÷)(z::FixedPoint, w::BigFixedPoint) = intdiv(z, w)

(%)(z::BigFixedPoint, w::BigFixedPoint) = rem(z, w)
(%)(z::FixedPoint, w::BigFixedPoint) = rem(z, w)

(log)(b::FixedPoint, z::BigFixedPoint) = (BigFixedPoint(log(BigFloat(BigFixedPoint(b)), BigFloat(z)), z.precision))
(log)(b::BigFixedPoint, z::FixedPoint) = (BigFixedPoint(log(BigFloat(b), BigFloat(BigFixedPoint(z))), z.precision))

(atan)(z::BigFixedPoint, w::FixedPoint) = (BigFixedPoint(atan(BigFloat(z), BigFloat(BigFixedPoint(w))), maxprecision(z, w)))
(atan)(z::FixedPoint, w::BigFixedPoint) = (BigFixedPoint(atan(BigFloat(BigFixedPoint(z)), BigFloat(w)), maxprecision(z, w)))

(hypot)(z::BigFixedPoint, w::FixedPoint) = (BigFixedPoint(hypot(BigFloat(z), BigFloat(BigFixedPoint(w))), maxprecision(z, w)))
(hypot)(z::FixedPoint, w::BigFixedPoint) = (BigFixedPoint(hypot(BigFloat(BigFixedPoint(z)), BigFloat(w)), maxprecision(z, w)))

(ldexp)(z::BigFixedPoint, w::FixedPoint) = (BigFixedPoint(ldexp(BigFloat(z), BigFloat(BigFixedPoint(w))), maxprecision(z, w)))
(ldexp)(z::FixedPoint, w::BigFixedPoint) = (BigFixedPoint(ldexp(BigFloat(BigFixedPoint(z)), BigFloat(w)), maxprecision(z, w)))

(prevpow)(z::BigFixedPoint, w::FixedPoint) = (BigFixedPoint(prevpow(BigFloat(z), BigFloat(BigFixPoint(w))), maxprecision(z, w)))
(prevpow)(z::FixedPoint, w::BigFixedPoint) = (BigFixedPoint(prevpow(BigFloat(BigFixedPoint(z)), BigFloat(w)), maxprecision(z, w)))

end