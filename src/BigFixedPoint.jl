import Base.BigFloat, Base.AbstractFloat, Base.convert, Base.string
import Base.==, Base.>=, Base.<=, Base.>, Base.<, Base.+, Base.-, Base.*, Base./, Base.^, Base.÷, Base.\, Base.%
import Base.√, Base.∛, Base.∜
import Base.show, Base.log, Base.log10, Base.log2, Base.sqrt, Base.exp, Base.exp2, Base.exp10, Base.div
import Base.sin, Base.sind, Base.cos, Base.cosd, Base.cosh ,Base.tan, Base.tand,  Base.sinh,  Base.cosc
import Base.cmp, Base.sincos, Base.sincosd, Base.sincospi, Base.asin, Base.sec, Base.secd, Base.sech
import Base.csc, Base.cscd, Base.csch, Base.cot, Base.cotd, Base.coth, Base.asec, Base.asecd, Base.asech
import Base.acsc, Base.acscd, Base.acsch, Base.acot, Base.acotd, Base.acoth, Base.asin, Base.asind, Base.asinh
import Base.asin, Base.asind, Base.asinh, Base.acos, Base.acosd, Base.acosh, Base.atan, Base.atand, Base.atanh
import Base.deg2rad, Base.rad2deg, Base.hypot, Base.log1p, Base.frexp, Base.ldexp, Base.modf, Base.trunc
import Base.ispow2, Base.invmod
import Base.round, Base.RoundingMode, Base.parse, Base.tryparse, Base.sign, Base.copysign
import Base.BigInt

export BigFixedPoint, scale, AbstractFloat, BigFloat, convert, string
export ==, >=, <=, >, <, +, -, *, /, ^, ÷, \, %, √, ∛, ∜
export show, log, log10, log2, sqrt, exp, exp2, exp10
export sin,  sind, cos, cosd, cosh, tan, tand
export cmp, sincos, sincosd, sincospi, asin, sec, secd, sech
export csc, cscd, csch, cot, cotd, coth, asec, asecd, asech
export acsc, acscd, ascsh, acot, acotd, acoth, asin, asind, asinh
export asin, asind, asinh, acos, acosd, acosh, atan, atand, atanh
export deg2rad, rad2deg, hypot, log1p, ldexp, modf, trunc
export ispow2, invmod
export round, parse, sign, copysign

# testing

"""
    BigFixedPoint(v,p)

Create a mutable struct that contains an integer value(v) with integer decimal places(p)

The value is always an integer. The p (precision) value determins how many decimal places are represented.

In the case that v is a float type, the number is rounded to p digits and then scaled to 10^p

# Examples
```
x = BigFixedPoint(4125,2)
println(x)
41.25
println(x * 2)
82.50 
```
All math operators are supported as well as most math functions. When calling math functions the number
is converted to a BigFloat and then back to BigFixedPoint type. The number of digits are preserved. When
types with mixed precision are mixed all operands and the result are widened to the maximum precision 
of all operands. The return type of equations and math functions are almost always goint to be a BigFixedPoint
type value.
"""
mutable struct BigFixedPoint{V<:BigInt,P<:Integer} <: AbstractFloat
    value::V
    precision::P

    function BigFixedPoint{V,P}(v::V, p::P) where {V<:BigInt,P<:Integer}
        new(v, p)
    end

end

BigFixedPoint(v::V, p::P) where {V<:BigInt, P<:Integer} = BigFixedPoint{V,P}(v, p)

function BigFixedPoint(v::V, p::P) where {V<:AbstractFloat, P<:Integer}
    if (v*(10^p)) > maxintfloat(typeof(v))
        throw(InexactError(BigFixedPoint, typeof(v), v))
    end    
    BigFixedPoint{BigInt,P}(Int(trunc(round(v; digits=p) * (10^p))), Int(p))
end

function BigFixedPoint(v::V, p::P) where {V<:BigFloat, P<:Integer}
    if (v*(10^p)) > maxintfloat(typeof(v))
        throw(InexactError(BigFixedPoint, typeof(v), v))
    end    
    BigFixedPoint{BigInt,P}(Int(trunc(round(v; digits=p) * (10^p))), Int(p))
end

function string(z::BigFixedPoint; base::Integer = 10, pad::Integer = 1)
    if base ≠ 10
        prinln("Warning: Bases other than 10 not yet implemented")
    end;
    if pad ≠ 1
        println("Warning: Pad not yet implemented")
    end
    s = string(abs(z.value))
    if z.value == 0
        fmt = "0." * repeat("0",z.precision)
    elseif length((s)) <= z.precision
        fmt = (z.value < 0 ? "-" : "") * "0" * (z.precision > 0 ? "." : "") * s[end-z.precision+1:end]
    else
        fmt = (z.value < 0 ? "-" : "") * s[1:end-z.precision] * (z.precision > 0 ? "." : "") * s[end-z.precision+1:end]
    end
    return fmt
end    

function show(io::IO, z::BigFixedPoint)
    fmt = string(z)
    print(io, fmt)
end

function sign(z::BigFixedPoint)
    if z.value == 0
        return BigFixedPoint(0,z.precision)
    else
        return z.value < 0 ? BigFixedPoint(-1 * 10^z.precision,z.precision) : BigFixedPoint(1 * 10^z.precision,z.precision)
    end
end

function copysign(z::BigFixedPoint, w::BigFixedPoint)
    x = BigFixedPoint(z.value, z.precision)
    if w.value >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function copysign(z::BigFixedPoint, w::Real)
    x = BigFixedPoint(z.value, z.precision)
    if w >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function scale(z::BigFixedPoint, w::BigFixedPoint)
    if z.precision == w.precision
        return (z, w)
    elseif z.precision > w.precision
        y = BigFixedPoint(w.value, w.precision)
        y.value = Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))
        y.precision = z.precision
        return (z, y)
    elseif z.precision < w.precision
        x = BigFixedPoint(z.value, z.precision)
        x.value = Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))
        x.precision = w.precision
        return (x, w)
    end
end
   
function scale!(z::BigFixedPoint, w::BigFixedPoint)
    if z.precision > w.precision
        w.value = Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))
        w.precision = z.precision
        return (z, w)
    else
        z.value = Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))
        z.precision = w.precision
        return (z, w)
    end
end

function eq(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision > w.precision ? (z.value == Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (w.value == Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))))
end

function neq(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision > w.precision ? (z.value != Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (w.value != Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))))
end

function gteq(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision > w.precision ? (z.value >= Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) >= w.value)
end

function lteq(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision > w.precision ? (z.value <= Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) <= w.value)
end

function gt(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision > w.precision ? (z.value > Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) > w.value)
end

function lt(z::BigFixedPoint, w::BigFixedPoint)
    return (z.precision < w.precision ? (z.value < Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) < w.value)
end

function add(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    return BigFixedPoint(x.value + y.value, x.precision)
end

function sub(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    return BigFixedPoint(x.value - y.value, x.precision)
end

function mul(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    sc = 10^x.precision
    return BigFixedPoint((x.value * y.value) ÷ ((x.value > sc || y.value > sc ? sc : 1)), x.precision)
end

function floatdiv(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    r = ((x.value % y.value) * (10^(x.precision + 1))) ÷ y.value
    if x.precision > 1
        if r % 10 >= 5
            return BigFixedPoint(((r ÷ 10) + 1) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        else
            return BigFixedPoint((r ÷ 10) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        end
    else
        return BigFixedPoint(x.value ÷ y.value,x.precision)
    end
end

function rem(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    return BigFixedPoint((x.value % y.value), x.precision)
end

function intdiv(z::BigFixedPoint, w::BigFixedPoint)::BigFixedPoint
    (x, y) = scale(z, w)
    return BigFixedPoint(((x.value ÷ y.value) * 10^(x.precision)), x.precision)
end

function pwr(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    result = round(BigFloat(x.value / 10^x.precision)^BigFloat(y.value / 10^y.precision), digits=2)
    return BigFixedPoint(result, x.precision)
end

function invdiv(z::BigFixedPoint, w::BigFixedPoint)
    return floatdiv(w, z)
end

function invmod(z::BigFixedPoint, w::BigFixedPoint)
    (x, y) = scale(z, w)
    return BigFixedPoint((y.value % x.value), x.precision)
end

function round(z::BigFixedPoint, r::RoundingMode=RoundNearest;
    digits::Union{Nothing,Integer}=nothing, sigdigits::Union{Nothing,Integer}=nothing, base::Union{Nothing,Integer}=nothing)
    nv = BigFixedPoint(z.value, z.precision)
    if sigdigits ≠ nothing
        println("Warning: sigdigits no implemented yet")
        return nv
    end
    if base ≠ nothing
        println("Warning: bases other than 10 are not implemented yet")
        return nv
    end
    if isnothing(digits)
        digits = 0
    end
    if nv.precision - digits > 0
        rem = (nv.value % (10^(nv.precision - digits))) ÷ 10^(nv.precision - digits - 1)
        if rem >= 5 && r != RoundToZero
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

function tryparse_internal(::Type{BigFixedPoint}, s::String)
    z = parse(BigFloat, s)
    n = BigFixedPoint(0,2)
    if !isnothing(findfirst('e',s))
        if findfirst('e',string(z))
            throw(InexactError(:parse, BigFixedPoint, s))
        end
    else
        decloc = findfirst('.',string(z))
        if isnothing(decloc)
           throw(ArgumentError("Cannot process $(s) a BigFixedPoint type"))
        else
            n.precision = length(s[decloc+1:end])
            n.value = Int(trunc(z*(10^n.precision)))
        end
    end
    return n
end
"""
    parse(::BigFixedPoint, s)

This function will parse a string and attempt to create BigFixedPoint type from it. It will attempt to determine
the precision from the number of digits to the right of the decimal point.

# Examples
```
x = parse(BigFixedPoint, "41.25")
println(x)
41.25
println(x * 2)
82.50 
```
"""
parse(::Type{BigFixedPoint}, s::AbstractString; kwargs...) = tryparse_internal(BigFixedPoint, s)

function cmp(z::BigFixedPoint, w::BigFixedPoint)::Integer
    (x,y) = scale(z,w)
    return isless(x.value, y.value)
end

function cmp(z::Integer, w::BigFixedPoint)::Integer
    (x,y) = scale(BigFixedPoint(z,0),w)
    return isless(x.value, y.value)
end

function cmp(z::BigFixedPoint, w::Integer)::Integer
    (x,y) = scale(w,BigFixedPoint(w,0))
    return isless(x.value, y.value)
end

function cmp(z::AbstractFloat, w::BigFixedPoint)::Integer
    (x,y) = scale(parse(BigFixedPoint, string(z)),w)
    return isless(x.value, y.value)
end

function cmp(z::BigFixedPoint, w::AbstractFloat)::Integer
    (x,y) = scale(z, parse(BigFixedPoint, string(w)))
    return isless(x.value, y.value)
end

function AbstractFloat(z::BigFixedPoint)
    return z.value / (10^z.precision)
end

function BigFloat(z::BigFixedPoint)
    return z.value / (10^z.precision)
end

function maxprecision(z::BigFixedPoint, w::BigFixedPoint)
    return max(z.precision, w.precision)
end

function modf(z::BigFixedPoint)
    s = z.value < 0 ? -1 : 1
    ipart = abs(z.value) ÷ (10^z.precision)
    fpart = abs(z.value) - (ipart * (10^z.precision))
    return (ipart * s, fpart * s)
end

(==)(z::BigFixedPoint, w::BigFixedPoint) = eq(z, w)
(==)(z::Integer, w::BigFixedPoint) = eq(BigFixedPoint(z,0), w)
(==)(z::BigFixedPoint, w::Integer) = eq(z, BigFixedPoint(w,0))
(==)(z::AbstractFloat, w::BigFixedPoint) = (z == BigFloat(w))
(==)(z::BigFixedPoint, w::AbstractFloat) = (BigFloat(z) == w)

(>=)(z::BigFixedPoint, w::BigFixedPoint) = gteq(z, w)
(>=)(z::Integer, w::BigFixedPoint) = gteq(BigFixedPoint(z,0), w)
(>=)(z::BigFixedPoint, w::Integer) = gteq(z, BigFixedPoint(w,0))
(>=)(z::AbstractFloat, w::BigFixedPoint) = (BigFloat(z) >= w)
(>=)(z::BigFixedPoint, w::AbstractFloat) = (z >- BigFloat(w))

(<=)(z::BigFixedPoint, w::BigFixedPoint) = lteq(z, w)
(<=)(z::Integer, w::BigFixedPoint) = lteq(BigFixedPoint(z,0), w)
(<=)(z::BigFixedPoint, w::Integer) = lteq(z, BigFixedPoint(w,0))
(<=)(z::AbstractFloat, w::BigFixedPoint) = (z <= BigFloat(w))
(<=)(z::BigFixedPoint, w::AbstractFloat) = (BigFloat(z) <= w)

(<)(z::BigFixedPoint, w::BigFixedPoint) = lt(z, w)
(<)(z::Integer, w::BigFixedPoint) = lt(BigFixedPoint(z,0), w)
(<)(z::BigFixedPoint, w::Integer) = lt(z, BigFixedPoint(w,0))
(<)(z::AbstractFloat, w::BigFixedPoint) = (z < BigFloat(w))
(<)(z::BigFixedPoint, w::AbstractFloat) = (BigFloat(z) < w)

(>)(z::BigFixedPoint, w::BigFixedPoint) = gt(z, w)
(>)(z::Integer, w::BigFixedPoint) = gt(BigFixedPoint(z,0), w)
(>)(z::BigFixedPoint, w::Integer) = gt(z, BigFixedPoint(w,0))
(>)(z::AbstractFloat, w::BigFixedPoint) = (z > BigFloat(w))
(>)(z::BigFixedPoint, w::AbstractFloat) = (BigFloat(z) > w)

(+)(z::BigFixedPoint, w::BigFixedPoint) = add(z, w)
(+)(z::Integer, w::BigFixedPoint) = add(BigFixedPoint(z,0), w)
(+)(z::BigFixedPoint, w::Integer) = add(z, BigFixedPoint(w,0))
(+)(z::AbstractFloat, w::BigFixedPoint) = add(parse(BigFixedPoint, string(z)), w)
(+)(z::BigFixedPoint, w::AbstractFloat) = add(z, parse(BigFixedPoint, string(w)))

(-)(z::BigFixedPoint, w::BigFixedPoint) = sub(z, w)
(-)(z::Integer, w::BigFixedPoint) = sub(BigFixedPoint(z,0), w)
(-)(z::BigFixedPoint, w::Integer) = sub(z, BigFixedPoint(w,0))
(-)(z::AbstractFloat, w::BigFixedPoint) = sub(parse(BigFixedPoint, string(z)), w)
(-)(z::BigFixedPoint, w::AbstractFloat) = sub(z, parse(BigFixedPoint, string(w)))

(*)(z::BigFixedPoint, w::BigFixedPoint) = mul(z, w)
(*)(z::Integer, w::BigFixedPoint) = mul(BigFixedPoint(z,0), w)
(*)(z::BigFixedPoint, w::Integer) = mul(z, BigFixedPoint(w,0))
(*)(z::AbstractFloat, w::BigFixedPoint) = mul(parse(BigFixedPoint, string(z)), w)
(*)(z::BigFixedPoint, w::AbstractFloat) = mul(z, parse(BigFixedPoint, string(w)))

(/)(z::BigFixedPoint, w::BigFixedPoint) = floatdiv(z, w)
(/)(z::Integer, w::BigFixedPoint) = floatdiv(BigFixedPoint(z,0), w)
(/)(z::BigFixedPoint, w::Integer) = floatdiv(z, BigFixedPoint(w,0))
(/)(z::AbstractFloat, w::BigFixedPoint) = floatdiv(parse(BigFixedPoint, string(z)), w)
(/)(z::BigFixedPoint, w::AbstractFloat) = floatdiv(z, parse(BigFixedPoint, string(w)))

(\)(z::BigFixedPoint, w::BigFixedPoint) = invdiv(z, w)
(\)(z::Integer, w::BigFixedPoint) = invdiv(BigFixedPoint(z,0), w)
(\)(z::BigFixedPoint, w::Integer) = invdiv(z, BigFixedPoint(w,0))
(\)(z::AbstractFloat, w::BigFixedPoint) = invdiv(parse(BigFixedPoint, string(z)), w)
(\)(z::BigFixedPoint, w::AbstractFloat) = invdiv(z, parse(BigFixedPoint, string(w)))

(^)(z::BigFixedPoint, w::BigFixedPoint) = pwr(z, w)
(^)(z::Integer, w::BigFixedPoint) = pwr(BigFixedPoint(z,0), w)
(^)(z::BigFixedPoint, w::Integer) = pwr(z, BigFixedPoint(w,0))
(^)(z::AbstractFloat, w::BigFixedPoint) = pwr(parse(BigFixedPoint, string(z)), w)
(^)(z::BigFixedPoint, w::AbstractFloat) = pwr(z, parse(BigFixedPoint, string(w)))

(÷)(z::BigFixedPoint, w::BigFixedPoint) = intdiv(z, w)
(÷)(z::Integer, w::BigFixedPoint) = intdiv(BigFixedPoint(z,0), w)
(÷)(z::BigFixedPoint, w::Integer) = intdiv(z, BigFixedPoint(w,0))
(÷)(z::AbstractFloat, w::BigFixedPoint) = intdiv(parse(BigFixedPoint, string(z)), w)
(÷)(z::BigFixedPoint, w::AbstractFloat) = intdiv(z, parse(BigFixedPoint, string(w)))

(%)(z::BigFixedPoint, w::BigFixedPoint) = rem(z, w)
(%)(z::Integer, w::BigFixedPoint) = rem(BigFixedPoint(z,0), w)
(%)(z::BigFixedPoint, w::Integer) = rem(z, BigFixedPoint(w,0))
(%)(z::AbstractFloat, w::BigFixedPoint) = rem(parse(BigFixedPoint, string(z)), w)
(%)(z::BigFixedPoint, w::AbstractFloat) = rem(z, parse(BigFixedPoint, string(w)))

(log)(z::BigFixedPoint) = (BigFixedPoint(log(BigFloat(z)),z.precision))
(log)(b::BigFixedPoint,z::BigFixedPoint) = (BigFixedPoint(log(BigFloat(b),BigFloat(z)),maxprecision(b,z)))
(log)(b::Number,z::BigFixedPoint) = (BigFixedPoint(log(b, BigFloat(z)), z.precision))
(log)(b::BigFixedPoint,z::Number) = (BigFixedPoint(log(BigFloat(b), z), z.precision))
(log10)(z::BigFixedPoint) = (BigFixedPoint(log10(BigFloat(z)), z.precision))
(log2)(z::BigFixedPoint) = (BigFixedPoint(log2(BigFloat(z)), z.precision))
(log1p)(z::BigFixedPoint) = (BigFixedPoint(log1p(BigFloat(z)), z.precision))

(exp)(z::BigFixedPoint) = (BigFixedPoint(exp(BigFloat(z)), z.precision))
(exp2)(z::BigFixedPoint) = (BigFixedPoint(exp2(BigFloat(z)), z.precision))
(exp10)(z::BigFixedPoint) = (BigFixedPoint(exp10(BigFloat(z)), z.precision))

(√)(z::BigFixedPoint) = (BigFixedPoint(√(BigFloat(z)), z.precision))
(∛)(z::BigFixedPoint) = (BigFixedPoint(∛(BigFloat(z)), z.precision))
(∜)(z::BigFixedPoint) = (BigFixedPoint(∜(BigFloat(z)), z.precision))

(cos)(z::BigFixedPoint) = (BigFixedPoint(cos(BigFloat(z)), z.precision))
(cosc)(z::BigFixedPoint) = (BigFixedPoint(cosc(BigFloat(z)), z.precision))
(cosd)(z::BigFixedPoint) = (BigFixedPoint(cosd(BigFloat(z)), z.precision))
(cosh)(z::BigFixedPoint) = (BigFixedPoint(cosh(BigFloat(z)), z.precision))

(tan)(z::BigFixedPoint) = (BigFixedPoint(tan(BigFloat(z)), z.precision))
(tanc)(z::BigFixedPoint) = (BigFixedPoint(tanc(BigFloat(z)), z.precision))
(tand)(z::BigFixedPoint) = (BigFixedPoint(tand(BigFloat(z)), z.precision))

(sin)(z::BigFixedPoint) = (BigFixedPoint(sin(BigFloat(z)), z.precision))
(sinc)(z::BigFixedPoint) = (BigFixedPoint(sinc(BigFloat(z)), z.precision))
(sind)(z::BigFixedPoint) = (BigFixedPoint(sind(BigFloat(z)), z.precision))
(sinh)(z::BigFixedPoint) = (BigFixedPoint(sinh(BigFloat(z)), z.precision))

(sincos)(z::BigFixedPoint) = (BigFixedPoint(sincos(BigFloat(z)), z.precision))
(sincosd)(z::BigFixedPoint) = (BigFixedPoint(sincosd(BigFloat(z)), z.precision))
(sincospi)(z::BigFixedPoint) = (BigFixedPoint(sincospi(BigFloat(z)), z.precision))

(atan)(z::BigFixedPoint) = (BigFixedPoint(atan(BigFloat(z)), z.precision))
(atan)(z::BigFixedPoint,w::BigFixedPoint) = (BigFixedPoint(atan(BigFloat(z),BigFloat(w)), maxprecision(z,w)))
(atan)(z::BigFixedPoint,w::Number) = (BigFixedPoint(atan(BigFloat(z),w), z.precision))
(atan)(z::Number,w::BigFixedPoint) = (BigFixedPoint(atan(z,BigFloat(w)), x.precision))
(atand)(z::BigFixedPoint) = (BigFixedPoint(atand(BigFloat(z)), z.precision))
(atanh)(z::BigFixedPoint) = (BigFixedPoint(atanh(BigFloat(z)), z.precision))

(sec)(z::BigFixedPoint) = (BigFixedPoint(sec(BigFloat(z)), z.precision))
(secd)(z::BigFixedPoint) = (BigFixedPoint(secd(BigFloat(z)), z.precision))
(sech)(z::BigFixedPoint) = (BigFixedPoint(sech(BigFloat(z)), z.precision))

(csc)(z::BigFixedPoint) = (BigFixedPoint(csc(BigFloat(z)), z.precision))
(cscd)(z::BigFixedPoint) = (BigFixedPoint(cscd(BigFloat(z)), z.precision))
(csch)(z::BigFixedPoint) = (BigFixedPoint(csch(BigFloat(z)), z.precision))

(cot)(z::BigFixedPoint) = (BigFixedPoint(cot(BigFloat(z)), z.precision))
(cotd)(z::BigFixedPoint) = (BigFixedPoint(cotd(BigFloat(z)), z.precision))
(coth)(z::BigFixedPoint) = (BigFixedPoint(coth(BigFloat(z)), z.precision))

(asec)(z::BigFixedPoint) = (BigFixedPoint(asec(BigFloat(z)), z.precision))
(asecd)(z::BigFixedPoint) = (BigFixedPoint(asecd(BigFloat(z)), z.precision))
(asech)(z::BigFixedPoint) = (BigFixedPoint(asech(BigFloat(z)), z.precision))

(acsc)(z::BigFixedPoint) = (BigFixedPoint(acsc(BigFloat(z)), z.precision))
(acscd)(z::BigFixedPoint) = (BigFixedPoint(acscd(BigFloat(z)), z.precision))
(acsch)(z::BigFixedPoint) = (BigFixedPoint(acsch(BigFloat(z)), z.precision))

(acot)(z::BigFixedPoint) = (BigFixedPoint(acot(BigFloat(z)), z.precision))
(acotd)(z::BigFixedPoint) = (BigFixedPoint(acotd(BigFloat(z)), z.precision))
(acoth)(z::BigFixedPoint) = (BigFixedPoint(acoth(BigFloat(z)), z.precision))

(asin)(z::BigFixedPoint) = (BigFixedPoint(asin(BigFloat(z)), z.precision))
(asind)(z::BigFixedPoint) = (BigFixedPoint(asind(BigFloat(z)), z.precision))
(asinh)(z::BigFixedPoint) = (BigFixedPoint(asinh(BigFloat(z)), z.precision))

(acos)(z::BigFixedPoint) = (BigFixedPoint(acos(BigFloat(z)), z.precision))
(acosd)(z::BigFixedPoint) = (BigFixedPoint(acosd(BigFloat(z)), z.precision))
(acosh)(z::BigFixedPoint) = (BigFixedPoint(acosh(BigFloat(z)), z.precision))

(deg2rad)(z::BigFixedPoint) = (BigFixedPoint(deg2rad(BigFloat(z)), z.precision))
(rad2deg)(z::BigFixedPoint) = (BigFixedPoint(rad2deg(BigFloat(z)), z.precision))

(hypot)(z::BigFixedPoint, w::BigFixedPoint) = (BigFixedPoint(hypot(BigFloat(z),BigFloat(w)), maxprecision(z,w)))
(hypot)(z::BigFixedPoint, w::Number) = (BigFixedPoint(hypot(BigFloat(z),w), z.precision))
(hypot)(z::Number, w::BigFixedPoint) = (BigFixedPoint(hypot(z,BigFloat(w)), w.precision))

(frexp)(z::BigFixedPoint) = (BigFixedPoint(frexp(BigFloat(z)), z.precision))

(ldexp)(z::BigFixedPoint, w::BigFixedPoint) = (BigFixedPoint(ldexp(BigFloat(z),BigFloat(w)), maxprecision(z,w)))

(-)(z::BigFixedPoint) = (BigFixedPoint(-(z.value), z.precision))
(+)(z::BigFixedPoint) = (BigFixedPoint(+(z.value), z.precision))

(ispow2)(z::BigFixedPoint) = (BigFixedPoint(ispow2(BigFloat(z)), z.precision))

(prevpow)(z::BigFixedPoint, w::BigFixedPoint) = (BigFixedPoint(prevpow(BigFloat(z),BigFloat(w)), maxprecision(z,w)))
(prevpow)(z::BigFixedPoint, w::Number) = (BigFixedPoint(prevpow(BigFloat(z),w), z.precision))
(prevpow)(z::Number, w::BigFixedPoint) = (BigFixedPoint(prevpow(z,BigFloat(w)), w.precision))
