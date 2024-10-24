module FixedPointNumerics

__precompile__(false)

import Base.Float64, Base.AbstractFloat, Base.convert
import Base.==, Base.>=, Base.<=, Base.>, Base.<, Base.+, Base.-, Base.*, Base./, Base.^, Base.÷, Base.\, Base.%
import Base.√, Base.∛, Base.∜
import Base.show, Base.log, Base.log10, Base.log2, Base.sqrt, Base.exp, Base.exp2, Base.exp10, Base.div
import Base.sin, Base.sind, Base.cos, Base.cosd, Base.cosh ,Base.tan, Base.tand,  Base.sinh,  Base.cosc
import Base.cmp, Base.sincos, Base.sincosd, Base.sincospi, Base.asin, Base.sec, Base.secd, Base.sech
import Base.csc, Base.cscd, Base.csch, Base.cot, Base.cotd, Base.coth, Base.asec, Base.asecd, Base.asech
import Base.acsc, Base.acscd, Base.acsch, Base.acot, Base.acotd, Base.acoth, Base.asin, Base.asind, Base.asinh
import Base.round, Base.RoundingMode, Base.parse, Base.tryparse

export FixedPoint, scale, AbstractFloat, Float64, convert
export ==, >=, <=, >, <, +, -, *, /, ^, ÷, \, %, √, ∛, ∜
export show, log, log10, log2, sqrt, exp, exp2, exp10
export sin,  sind, cos, cosd, cosh, tan, tand
export cmp, sincos, sincosd, sincospi, asin, sec, secd, sech
export csc, cscd, csch, cot, cotd, coth, asec, asecd, asech
export acsc, acscd, ascsh
export round, parse

mutable struct FixedPoint{V<:Integer,P<:Integer} <: Real
    value::V
    precision::P

    function FixedPoint{V,P}(v::V, p::P) where {V<:Integer,P<:Integer}
        new(v, p)
    end

end

FixedPoint(v::V, p::P) where {V<:Int64, P<:Integer} = FixedPoint{V,P}(v, p)

FixedPoint(v::V, p::P) where {V<:Int128, P<:Integer} = FixedPoint{V,P}(v, p)

function FixedPoint(v::V, p::P) where {V<:AbstractFloat, P<:Integer}
    if (v*(10^p)) > maxintfloat(typeof(v))
        throw(InexactError(FixedPoint, typeof(v), v))
    end    
    FixedPoint{Int64,P}(Int64(trunc(round(v; digits=p) * (10^p))), Int64(p))
end

function show(io::IO, z::FixedPoint)
    s = string(abs(z.value))
    if z.value == 0
        fmt = "0.0"
    elseif length((s)) <= z.precision
        fmt = (z.value < 0 ? "-" : "") * "0." * s[end-z.precision+1:end]
    else
        fmt = (z.value < 0 ? "-" : "") * s[1:end-z.precision] * '.' * s[end-z.precision+1:end]
    end
    print(io, fmt)
end

function scale(z::FixedPoint, w::FixedPoint)
    if z.precision == w.precision
        return (z, w)
    elseif z.precision > w.precision
        y = FixedPoint(w.value, w.precision)
        y.value = Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))
        y.precision = z.precision
        return (z, y)
    elseif z.precision < w.precision
        x = FixedPoint(z.value, z.precision)
        x.value = Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))
        x.precision = w.precision
        return (x, w)
    end
end

function scale!(z::FixedPoint, w::FixedPoint)
    if z.precision > w.precision
        w.value = Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))
        w.precision = z.precision
        return (z, w)
    else
        z.value = Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))
        z.precision = w.precision
        return (z, w)
    end
end

function eq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value == Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (w.value == Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))))
end

function neq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value != Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (w.value != Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))))
end

function gteq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value >= Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))) >= w.value)
end

function lteq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value <= Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))) <= w.value)
end

function gt(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value > Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))) > w.value)
end

function lt(z::FixedPoint, w::FixedPoint)
    return (z.precision < w.precision ? (z.value < Int64(trunc((Int64(w.value) * 10^(z.precision - w.precision))))) : (Int64(trunc((Int64(z.value) * 10^(w.precision - z.precision))))) < w.value)
end

function add(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint(x.value + y.value, x.precision)
end

function add(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint(x.value + y.value, x.precision)
end

function sub(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint(x.value - y.value, x.precision)
end

function mul(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    sc = 10^x.precision
    return FixedPoint((x.value * y.value) ÷ ((x.value > sc || y.value > sc ? sc : 1)), x.precision)
end

function floatdiv(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    r = ((x.value % y.value) * (10^(x.precision + 1))) ÷ y.value
    if x.precision > 1
        if r % 10 >= 5
            return FixedPoint(((r ÷ 10) + 1) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        else
            return FixedPoint((r ÷ 10) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        end
    else
        return FixedPoint(x.value ÷ y.value,x.precision)
    end
end

function rem(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint((x.value % y.value), x.precision)
end

function intdiv(z::FixedPoint, w::FixedPoint)::FixedPoint
    (x, y) = scale(z, w)
    return FixedPoint(((x.value ÷ y.value) * 10^(x.precision)), x.precision)
end

function pwr(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    result = round(Float64(x.value / 10^x.precision)^Float64(y.value / 10^y.precision), digits=2)
    return FixedPoint(result, x.precision)
end

function invdiv(z::FixedPoint, w::FixedPoint)
    return floatdiv(w, z)
end

function round(z::FixedPoint, r::RoundingMode=RoundNearest;
    digits::Union{Nothing,Integer}=nothing, sigdigits::Union{Nothing,Integer}=nothing, base::Union{Nothing,Integer}=nothing)
    nv = FixedPoint(z.value, z.precision)
    if sigdigits ≠ nothing
        println("Warning: sigdigits no implemented yet")
        return nv
    end
    if base ≠ nothing
        println("Warning: bases other than 10 are not implemented yet")
        return nv
    end
    if nv.precision - digits > 0
        rem = (nv.value % (10^(nv.precision - digits))) ÷ 10^(nv.precision - digits - 1)
        if rem >= 5
            nv.value = (nv.value ÷ (10^(nv.precision - digits))) + 1
        else
            nv.value = (nv.value ÷ (10^(nv.precision - digits)))
        end
    else
        nv.value = (nv.value * (10^(digits - nv.precision)))
    end
    nv.precision = digits
    return nv
end

function tryparse_internal(::Type{FixedPoint}, s::String)
    z = parse(Float64, s)
    n = FixedPoint(0,2)
    if !isnothing(findfirst('e',s))
        if findfirst('e',string(z))
            throw(InexactError(:parse, FixedPoint, s))
        end
    else
        decloc = findfirst('.',string(z))
        if isnothing(decloc)
           throw(ArgumentError("Cannot process $(s) a FixedPoint type"))
        else
            n.precision = length(s[decloc+1:end])
            n.value = Int64(trunc(z*(10^n.precision)))
        end
    end
    return n
end

parse(::Type{FixedPoint}, s::AbstractString; kwargs...) = tryparse_internal(FixedPoint, s)

function cmp(z::FixedPoint, w::FixedPoint)::Integer
    (x,y) = scale(z,w)
    return isless(x.value, y.value)
end

function cmp(z::Integer, w::FixedPoint)::Integer
    (x,y) = scale(FixedPoint(z,0),w)
    return isless(x.value, y.value)
end

function cmp(z::FixedPoint, w::Integer)::Integer
    (x,y) = scale(w,FixedPoint(w,0))
    return isless(x.value, y.value)
end

function cmp(z::AbstractFloat, w::FixedPoint)::Integer
    (x,y) = scale(parse(FixedPoint, string(z)),w)
    return isless(x.value, y.value)
end

function cmp(z::FixedPoint, w::AbstractFloat)::Integer
    (x,y) = scale(z, parse(FixedPoint, string(w)))
    return isless(x.value, y.value)
end

function AbstractFloat(x::FixedPoint)
    return x.value / (10^x.precision)
end

function Float64(x::FixedPoint)
    return x.value / (10^x.precision)
end

(==)(z::FixedPoint, w::FixedPoint) = eq(z, w)
(==)(z::Integer, w::FixedPoint) = eq(FixedPoint(z,0), w)
(==)(z::FixedPoint, w::Integer) = eq(z, FixedPoint(w,0))
(==)(z::AbstractFloat, w::FixedPoint) = eq(parse(FixedPoint, string(z)), w)
(==)(z::FixedPoint, w::AbstractFloat) = eq(z, parse(FixedPoint, string(w)))

(>=)(z::FixedPoint, w::FixedPoint) = gteq(z, w)
(>=)(z::Integer, w::FixedPoint) = gteq(FixedPoint(z,0), w)
(>=)(z::FixedPoint, w::Integer) = gteq(z, FixedPoint(w,0))
(>=)(z::AbstractFloat, w::FixedPoint) = gteq(parse(FixedPoint, string(z)), w)
(>=)(z::FixedPoint, w::AbstractFloat) = gteq(z, parse(FixedPoint, string(w)))

(<=)(z::FixedPoint, w::FixedPoint) = lteq(z, w)
(<=)(z::Integer, w::FixedPoint) = lteq(FixedPoint(z,0), w)
(<=)(z::FixedPoint, w::Integer) = lteq(z, FixedPoint(w,0))
(<=)(z::AbstractFloat, w::FixedPoint) = lteq(parse(FixedPoint, string(z)), w)
(<=)(z::FixedPoint, w::AbstractFloat) = lteq(z, parse(FixedPoint, string(w)))

(<)(z::FixedPoint, w::FixedPoint) = lt(z, w)
(<)(z::Integer, w::FixedPoint) = lt(FixedPoint(z,0), w)
(<)(z::FixedPoint, w::Integer) = lt(z, FixedPoint(w,0))
(<)(z::AbstractFloat, w::FixedPoint) = lt(parse(FixedPoint, string(z)), w)
(<)(z::FixedPoint, w::AbstractFloat) = lt(z, parse(FixedPoint, string(w)))

(>)(z::FixedPoint, w::FixedPoint) = gt(z, w)
(>)(z::Integer, w::FixedPoint) = gt(FixedPoint(z,0), w)
(>)(z::FixedPoint, w::Integer) = gt(z, FixedPoint(w,0))
(>)(z::AbstractFloat, w::FixedPoint) = gt(parse(FixedPoint, string(z)), w)
(>)(z::FixedPoint, w::AbstractFloat) = gt(z, parse(FixedPoint, string(w)))

(+)(z::FixedPoint, w::FixedPoint) = add(z, w)
(+)(z::Integer, w::FixedPoint) = add(FixedPoint(z,0), w)
(+)(z::FixedPoint, w::Integer) = add(z, FixedPoint(w,0))
(+)(z::AbstractFloat, w::FixedPoint) = add(parse(FixedPoint, string(z)), w)
(+)(z::FixedPoint, w::AbstractFloat) = add(z, parse(FixedPoint, string(w)))

(-)(z::FixedPoint, w::FixedPoint) = sub(z, w)
(-)(z::Integer, w::FixedPoint) = sub(FixedPoint(z,0), w)
(-)(z::FixedPoint, w::Integer) = sub(z, FixedPoint(w,0))
(-)(z::AbstractFloat, w::FixedPoint) = sub(parse(FixedPoint, string(z)), w)
(-)(z::FixedPoint, w::AbstractFloat) = sub(z, parse(FixedPoint, string(w)))

(*)(z::FixedPoint, w::FixedPoint) = mul(z, w)
(*)(z::Integer, w::FixedPoint) = mul(FixedPoint(z,0), w)
(*)(z::FixedPoint, w::Integer) = mul(z, FixedPoint(w,0))
(*)(z::AbstractFloat, w::FixedPoint) = mul(parse(FixedPoint, string(z)), w)
(*)(z::FixedPoint, w::AbstractFloat) = mul(z, parse(FixedPoint, string(w)))

(/)(z::FixedPoint, w::FixedPoint) = floatdiv(z, w)
(/)(z::Integer, w::FixedPoint) = floatdiv(FixedPoint(z,0), w)
(/)(z::FixedPoint, w::Integer) = floatdiv(z, FixedPoint(w,0))
(/)(z::AbstractFloat, w::FixedPoint) = floatdiv(parse(FixedPoint, string(z)), w)
(/)(z::FixedPoint, w::AbstractFloat) = floatdiv(z, parse(FixedPoint, string(w)))

(\)(z::FixedPoint, w::FixedPoint) = invdiv(z, w)
(\)(z::Integer, w::FixedPoint) = invdiv(FixedPoint(z,0), w)
(\)(z::FixedPoint, w::Integer) = invdiv(z, FixedPoint(w,0))
(\)(z::AbstractFloat, w::FixedPoint) = invdiv(parse(FixedPoint, string(z)), w)
(\)(z::FixedPoint, w::AbstractFloat) = invdiv(z, parse(FixedPoint, string(w)))

(^)(z::FixedPoint, w::FixedPoint) = pwr(z, w)
(^)(z::Integer, w::FixedPoint) = pwr(FixedPoint(z,0), w)
(^)(z::FixedPoint, w::Integer) = pwr(z, FixedPoint(w,0))
(^)(z::AbstractFloat, w::FixedPoint) = pwr(parse(FixedPoint, string(z)), w)
(^)(z::FixedPoint, w::AbstractFloat) = pwr(z, parse(FixedPoint, string(w)))

(÷)(z::FixedPoint, w::FixedPoint) = intdiv(z, w)
(÷)(z::Integer, w::FixedPoint) = intdiv(FixedPoint(z,0), w)
(÷)(z::FixedPoint, w::Integer) = intdiv(z, FixedPoint(w,0))
(÷)(z::AbstractFloat, w::FixedPoint) = intdiv(parse(FixedPoint, string(z)), w)
(÷)(z::FixedPoint, w::AbstractFloat) = intdiv(z, parse(FixedPoint, string(w)))

(%)(z::FixedPoint, w::FixedPoint) = rem(z, w)
(%)(z::Integer, w::FixedPoint) = rem(FixedPoint(z,0), w)
(%)(z::FixedPoint, w::Integer) = rem(z, FixedPoint(w,0))
(%)(z::AbstractFloat, w::FixedPoint) = rem(parse(FixedPoint, string(z)), w)
(%)(z::FixedPoint, w::AbstractFloat) = rem(z, parse(FixedPoint, string(w)))

(log)(z::FixedPoint) = (FixedPoint(log(Float64(z)),z.precision))
(log10)(z::FixedPoint) = (FixedPoint(log10(Float64(z)), z.precision))
(log2)(z::FixedPoint) = (FixedPoint(log2(Float64(z)), z.precision))
(exp)(z::FixedPoint) = (FixedPoint(exp(Float64(z)), z.precision))
(exp2)(z::FixedPoint) = (FixedPoint(exp2(Float64(z)), z.precision))
(exp10)(z::FixedPoint) = (FixedPoint(exp10(Float64(z)), z.precision))
(sqrt)(z::FixedPoint) = (FixedPoint(sqrt(Float64(z)), z.precision))
(√)(z::FixedPoint) = (FixedPoint(sqrt(Float64(z)), z.precision))
(∛)(z::FixedPoint) = (FixedPoint(∛(Float64(z)), z.precision))
(∜)(z::FixedPoint) = (FixedPoint(∜(Float64(z)), z.precision))

(cos)(z::FixedPoint) = (FixedPoint(cos(Float64(z)), z.precision))
(cosc)(z::FixedPoint) = (FixedPoint(cosc(Float64(z)), z.precision))
(cosd)(z::FixedPoint) = (FixedPoint(cosd(Float64(z)), z.precision))
(cosh)(z::FixedPoint) = (FixedPoint(cosh(Float64(z)), z.precision))

(tan)(z::FixedPoint) = (FixedPoint(tan(Float64(z)), z.precision))
(tanc)(z::FixedPoint) = (FixedPoint(tanc(Float64(z)), z.precision))
(tand)(z::FixedPoint) = (FixedPoint(tand(Float64(z)), z.precision))

(sin)(z::FixedPoint) = (FixedPoint(sin(Float64(z)), z.precision))
(sinc)(z::FixedPoint) = (FixedPoint(sinc(Float64(z)), z.precision))
(sind)(z::FixedPoint) = (FixedPoint(sind(Float64(z)), z.precision))
(sinh)(z::FixedPoint) = (FixedPoint(sinh(Float64(z)), z.precision))

(sincos)(z::FixedPoint) = (FixedPoint(sincos(Float64(z)), z.precision))
(sincosd)(z::FixedPoint) = (FixedPoint(sincosd(Float64(z)), z.precision))
(sincospi)(z::FixedPoint) = (FixedPoint(sincospi(Float64(z)), z.precision))

(atan)(x::FixedPoint) = (FixedPoint(atan(Float64(x)), x.precision))
(atan)(x::FixedPoint,y::FixedPoint) = (FixedPoint(atan(Float64(x),Float64(y)), max(x.precision,y.precision)))
(atan)(x::FixedPoint,y::Number) = (FixedPoint(atan(Float64(x),y), x.precision))
(atan)(x::Number,y::FixedPoint) = (FixedPoint(atan(x,Float64(y)), y.precision))

(sec)(z::FixedPoint) = (FixedPoint(sec(Float64(z)), z.precision))
(secd)(z::FixedPoint) = (FixedPoint(secd(Float64(z)), z.precision))
(sech)(z::FixedPoint) = (FixedPoint(sech(Float64(z)), z.precision))

(csc)(z::FixedPoint) = (FixedPoint(csc(Float64(z)), z.precision))
(cscd)(z::FixedPoint) = (FixedPoint(cscd(Float64(z)), z.precision))
(csch)(z::FixedPoint) = (FixedPoint(csch(Float64(z)), z.precision))

(cot)(z::FixedPoint) = (FixedPoint(cot(Float64(z)), z.precision))
(cotd)(z::FixedPoint) = (FixedPoint(cotd(Float64(z)), z.precision))
(coth)(z::FixedPoint) = (FixedPoint(coth(Float64(z)), z.precision))

(asec)(z::FixedPoint) = (FixedPoint(asec(Float64(z)), z.precision))
(asecd)(z::FixedPoint) = (FixedPoint(asecd(Float64(z)), z.precision))
(asech)(z::FixedPoint) = (FixedPoint(asech(Float64(z)), z.precision))

(acsc)(z::FixedPoint) = (FixedPoint(acsc(Float64(z)), z.precision))
(acscd)(z::FixedPoint) = (FixedPoint(acscd(Float64(z)), z.precision))
(acsch)(z::FixedPoint) = (FixedPoint(acsch(Float64(z)), z.precision))

(acot)(z::FixedPoint) = (FixedPoint(acot(Float64(z)), z.precision))
(acotd)(z::FixedPoint) = (FixedPoint(acotd(Float64(z)), z.precision))
(acoth)(z::FixedPoint) = (FixedPoint(acoth(Float64(z)), z.precision))

(-)(z::FixedPoint) = (FixedPoint(-(z.value), z.precision))
(+)(z::FixedPoint) = (FixedPoint(+(z.value), z.precision))

end