import Base.Float64, Base.AbstractFloat, Base.convert, Base.string
import Base.==, Base.>=, Base.<=, Base.>, Base.<, Base.+, Base.-, Base.*, Base./, Base.^, Base.÷, Base.\, Base.%
import Base.√, Base.∛, Base.∜
import Base.show, Base.log, Base.log10, Base.log2, Base.sqrt, Base.exp, Base.exp2, Base.exp10, Base.div
import Base.sin, Base.sind, Base.cos, Base.cosd, Base.cosh, Base.tan, Base.tand, Base.sinh, Base.cosc
import Base.cmp, Base.sincos, Base.sincosd, Base.sincospi, Base.asin, Base.sec, Base.secd, Base.sech
import Base.csc, Base.cscd, Base.csch, Base.cot, Base.cotd, Base.coth, Base.asec, Base.asecd, Base.asech
import Base.acsc, Base.acscd, Base.acsch, Base.acot, Base.acotd, Base.acoth, Base.asin, Base.asind, Base.asinh
import Base.asin, Base.asind, Base.asinh, Base.acos, Base.acosd, Base.acosh, Base.atan, Base.atand, Base.atanh
import Base.deg2rad, Base.rad2deg, Base.hypot, Base.log1p, Base.frexp, Base.ldexp, Base.modf, Base.trunc
import Base.ispow2, Base.invmod, Base.signbit, Base.rem2pi
import Base.round, Base.RoundingMode, Base.parse, Base.tryparse, Base.sign, Base.copysign

"""
    FixedPoint(v,p)

Create a mutable struct that contains an integer value(v) with integer decimal places(p)

The value is always an integer. The p (precision) value determins how many decimal places are represented.

In the case that v is a float type, the number is rounded to p digits and then scaled to 10^p

# Examples
```
x = FixedPoint(4125,2)
println(x)
41.25
println(x * 2)
82.50 
```
All math operators are supported as well as most math functions. When calling math functions the number
is converted to a Float and then back to FixedPoint type. The number of digits are preserved. When
types with mixed precision are mixed all operands and the result are widened to the maximum precision 
of all operands. The return type of equations and math functions are almost always goint to be a FixedPoint
type value.
"""
mutable struct FixedPoint{V<:Integer,P<:Integer} <: AbstractFloat
    value::V
    precision::P

    function FixedPoint{V,P}(v::V, p::P) where {V<:Integer,P<:Integer}
        new(v, p)
    end

end

FixedPoint(v::V, p::P) where {V<:Int,P<:Integer} = FixedPoint{V,P}(v, p)

FixedPoint(v::V, p::P) where {V<:Int128,P<:Integer} = FixedPoint{V,P}(v, p)

function FixedPoint(v::V) where {V<:AbstractFloat}
    x = string(v)
    return tryparse_internal(FixedPoint, x)
end

function FixedPoint(s::S) where {S<:AbstractString}
    decloc = findfirst('.', s)
    v = 0
    try
        v = parse(Int, replace(s, "." => ""))
    catch
        v = 0
    end
    p = length(s[decloc+1:end])
    return FixedPoint(v, p)
end

function FixedPoint(v::V, p::P) where {V<:AbstractFloat,P<:Integer}
    if (v * (10^p)) > maxintfloat(typeof(v))
        throw(InexactError(FixedPoint, typeof(v), v))
    end
    FixedPoint{Int,P}(Int(trunc(round(v; digits=p) * (10^p))), Int(p))
end

function string(z::FixedPoint; base::Integer=10, pad::Integer=1)
    if base ≠ 10
        prinln("Warning: Bases other than 10 not yet implemented")
    end
    if pad ≠ 1
        println("Warning: Pad not yet implemented")
    end
    s = string(abs(z.value))
    if z.value == 0
        fmt = "0." * repeat("0", z.precision)
    elseif length(s) < z.precision 
        fmt = (z.value < 0 ? "-" : "") * "0" * (z.precision > 0 ? "." : "") * repeat("0", z.precision - length(s)) *s[1:end]
    elseif length((s)) == z.precision
        fmt = (z.value < 0 ? "-" : "") * "0" * (z.precision > 0 ? "." : "") * s[end-z.precision+1:end]
    else
        fmt = (z.value < 0 ? "-" : "") * s[1:end-z.precision] * (z.precision > 0 ? "." : "") * s[end-z.precision+1:end]
    end
    return fmt
end

function show(io::IO, z::FixedPoint)
    fmt = string(z)
    print(io, fmt)
end

function sign(z::FixedPoint)
    if z.value == 0
        return FixedPoint(0, z.precision)
    else
        return z.value < 0 ? FixedPoint(-1 * 10^z.precision, z.precision) : FixedPoint(1 * 10^z.precision, z.precision)
    end
end

function copysign(z::FixedPoint, w::FixedPoint)
    x = FixedPoint(z.value, z.precision)
    if w.value >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function copysign(z::FixedPoint, w::Real)
    x = FixedPoint(z.value, z.precision)
    if w >= 0
        x.value = abs(x.value)
        return x
    else
        x.value = -(abs(x.value))
        return x
    end
end

function scale(z::FixedPoint, w::FixedPoint)
    if z.precision == w.precision
        return (z, w)
    elseif z.precision > w.precision
        y = FixedPoint(w.value, w.precision)
        y.value = Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))
        y.precision = z.precision
        return (z, y)
    elseif z.precision < w.precision
        x = FixedPoint(z.value, z.precision)
        x.value = Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))
        x.precision = w.precision
        return (x, w)
    end
end

function scale!(z::FixedPoint, w::FixedPoint)
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

function eq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value == Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (w.value == Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))))
end

function neq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value != Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (w.value != Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))))
end

function gteq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value >= Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) >= w.value)
end

function lteq(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value <= Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) <= w.value)
end

function gt(z::FixedPoint, w::FixedPoint)
    return (z.precision > w.precision ? (z.value > Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) > w.value)
end

function lt(z::FixedPoint, w::FixedPoint)
    return (z.precision < w.precision ? (z.value < Int(trunc((Int(w.value) * 10^(z.precision - w.precision))))) : (Int(trunc((Int(z.value) * 10^(w.precision - z.precision))))) < w.value)
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
    if x.precision > 0
        return FixedPoint((r ÷ 10) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
    else
        return FixedPoint(x.value ÷ y.value, x.precision)
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

function invmod(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint((y.value % x.value), x.precision)
end

function signbit(z::FixedPoint)
    return signbit(z.value)
end

function round(z::FixedPoint, ::RoundingMode{:NearestTiesAway})
    nv = FixedPoint(z.value, z.precision)
    rem = (nv.value % (10^(nv.precision)))
    if abs(rem) >= 5
        nv.value = ((z.value ÷ (10^(z.precision))) + copysign(1, z.value)) * (10^(z.precision))
    else
        nv.value = (z.value ÷ (10^(z.precision))) * (10^(z.precision))
    end
    return nv
end

function round(z::FixedPoint, ::RoundingMode{:NearestTiesUp})
    nv = FixedPoint(z.value, z.precision)
    rem = (nv.value % (10^(nv.precision)))
    if abs(rem) >= 5
        nv.value = ((z.value ÷ (10^(z.precision))) + 1) * (10^(z.precision))
    else
        nv.value = (z.value ÷ (10^(z.precision))) * (10^(z.precision))
    end
    return nv
end

function round(z::FixedPoint, ::RoundingMode{:FromZero})
    nv = FixedPoint(z.value, z.precision)
    rem = (nv.value % (10^(nv.precision)))
    if abs(rem) > 0
        nv.value = ((z.value ÷ (10^(z.precision))) + copysign(1, z.value)) * (10^(z.precision))
    else
        nv.value = (z.value ÷ (10^(z.precision))) * (10^(z.precision))
    end
    return nv
end

function round(z::FixedPoint, ::RoundingMode{:ToZero})
    nv = FixedPoint(z.value, z.precision)
    rem = (nv.value % (10^(nv.precision)))
    if abs(rem) > 0
        nv.value = ((z.value ÷ (10^(z.precision))) - copysign(1, z.value)) * (10^(z.precision))
    else
        nv.value = ((z.value ÷ (10^(z.precision)))) * (10^(z.precision))
    end
    return nv
end

function round(z::FixedPoint, ::RoundingMode{:Up})
    nv = FixedPoint(z.value, z.precision)
    nv.value = ((z.value ÷ (10^(z.precision))) + 1) * (10^(z.precision))
    return nv
end

function round(z::FixedPoint, ::RoundingMode{:Down})
    nv = FixedPoint(z.value, z.precision)
    nv.value = ((z.value ÷ (10^(z.precision))) - 1) * (10^(z.precision))
    return nv
end

function round(z::FixedPoint, r::RoundingMode=RoundNearest;
    digits::Union{Nothing,Integer}=nothing, sigdigits::Union{Nothing,Integer}=nothing, base::Union{Nothing,Integer}=nothing)
    if digits === nothing
        if sigdigits === nothing
            if base === nothing
                # avoid recursive calls
                if r == RoundNearest
                    return round(z, RoundNearestTiesUp)
                else
                    return round(z, r)
                end
                #throw(MethodError(round, (z, r)))
            else
                if r == RoundNearest
                    return round(z, RoundNearestTiesUp)
                else
                    return round(z, r)
                end
            end
        else
            nv = FixedPoint(z.value, z.precision)
            nv.value = round(nv.value, r; sigdigits=sigdigits)
            return nv
        end
    else
        if sigdigits === nothing
            nv = FixedPoint(z.value, 0)
            d = z.precision - digits
            if  d > 0
                for p in 1:d
                    nv.precision = p
                    if r == RoundNearest
                        nv = round(nv, RoundNearestTiesUp)
                    else
                        nv = round(nv, r)
                    end                    
                end
                nv.precision = z.precision
                return nv 
            else
                nv.precision = z.precision
                return nv
            end
        else
            throw(ArgumentError("`round` cannot use both `digits` and `sigdigits` arguments."))
        end
    end
end

function tryparse_internal(::Type{FixedPoint}, s::String)
    z = parse(Float64, s)
    n = FixedPoint(0, 2)
    if !isnothing(findfirst('e', s))
        if findfirst('e', string(z))
            throw(InexactError(:parse, FixedPoint, s))
        end
    else
        decloc = findfirst('.', string(z))
        if isnothing(decloc)
            throw(ArgumentError("Cannot process $(s) as a FixedPoint type"))
        else
            n.precision = length(s[decloc+1:end])
            n.value = Int(trunc(z * (10^n.precision)))
        end
    end
    return n
end
"""
    parse(::FixedPoint, s)

This function will parse a string and attempt to create FixedPoint type from it. It will attempt to determine
the precision from the number of digits to the right of the decimal point.

# Examples
```
x = parse(FixedPoint, "41.25")
println(x)
41.25
println(x * 2)
82.50 
```
"""
parse(::Type{FixedPoint}, s::AbstractString) = tryparse_internal(FixedPoint, s)

#parse(::Type{FixedPoint}, s::AbstractString; kwargs...) = tryparse_internal(FixedPoint, s)

function cmp(z::FixedPoint, w::FixedPoint)::Integer
    (x, y) = scale(z, w)
    return isless(x.value, y.value)
end

function cmp(z::Integer, w::FixedPoint)::Integer
    (x, y) = scale(FixedPoint(z, 0), w)
    return isless(x.value, y.value)
end

function cmp(z::FixedPoint, w::Integer)::Integer
    (x, y) = scale(z, FixedPoint(w, 0))
    return isless(x.value, y.value)
end

function cmp(z::AbstractFloat, w::FixedPoint)::Integer
    (x, y) = scale(parse(FixedPoint, string(z)), w)
    return isless(x.value, y.value)
end

function cmp(z::FixedPoint, w::AbstractFloat)::Integer
    (x, y) = scale(z, parse(FixedPoint, string(w)))
    return isless(x.value, y.value)
end

function AbstractFloat(z::FixedPoint)
    return z.value / (10^z.precision)
end

function Float64(z::FixedPoint)
    return z.value / (10^z.precision)
end

function maxprecision(z::FixedPoint, w::FixedPoint)
    return max(z.precision, w.precision)
end

function modf(z::FixedPoint)
    s = z.value < 0 ? -1 : 1
    ipart = abs(z.value) ÷ (10^z.precision)
    fpart = abs(z.value) - (ipart * (10^z.precision))
    return (ipart * s, fpart * s)
end

(==)(z::FixedPoint, w::FixedPoint) = eq(z, w)
(==)(z::Integer, w::FixedPoint) = eq(FixedPoint(z, 0), w)
(==)(z::FixedPoint, w::Integer) = eq(z, FixedPoint(w, 0))
(==)(z::AbstractFloat, w::FixedPoint) = (z == Float64(w))
(==)(z::FixedPoint, w::AbstractFloat) = (Float64(z) == w)
(==)(z::AbstractString, w::FixedPoint) = eq(FixedPoint(z), w)
(==)(z::FixedPoint, w::AbstractString) = eq(z, FixedPoint(w))

(>=)(z::FixedPoint, w::FixedPoint) = gteq(z, w)
(>=)(z::Integer, w::FixedPoint) = gteq(FixedPoint(z, 0), w)
(>=)(z::FixedPoint, w::Integer) = gteq(z, FixedPoint(w, 0))
(>=)(z::AbstractFloat, w::FixedPoint) = (Float64(z) >= w)
(>=)(z::FixedPoint, w::AbstractFloat) = (z > -Float64(w))
(>=)(z::AbstractString, w::FixedPoint) = gteq(FixedPoint(z), w)
(>=)(z::FixedPoint, w::AbstractString) = gteq(z, FixedPoint(w))

(<=)(z::FixedPoint, w::FixedPoint) = lteq(z, w)
(<=)(z::Integer, w::FixedPoint) = lteq(FixedPoint(z, 0), w)
(<=)(z::FixedPoint, w::Integer) = lteq(z, FixedPoint(w, 0))
(<=)(z::AbstractFloat, w::FixedPoint) = (z <= Float64(w))
(<=)(z::FixedPoint, w::AbstractFloat) = (Float64(z) <= w)
(<=)(z::AbstractString, w::FixedPoint) = lteq(FixedPoint(z), w)
(<=)(z::FixedPoint, w::AbstractString) = lteq(z, FixedPoint(w))

(<)(z::FixedPoint, w::FixedPoint) = lt(z, w)
(<)(z::Integer, w::FixedPoint) = lt(FixedPoint(z, 0), w)
(<)(z::FixedPoint, w::Integer) = lt(z, FixedPoint(w, 0))
(<)(z::AbstractFloat, w::FixedPoint) = (z < Float64(w))
(<)(z::FixedPoint, w::AbstractFloat) = (Float64(z) < w)
(<)(z::AbstractString, w::FixedPoint) = lt(FixedPoint(z), w)
(<)(z::FixedPoint, w::AbstractString) = lt(z, FixedPoint(w))

(>)(z::FixedPoint, w::FixedPoint) = gt(z, w)
(>)(z::Integer, w::FixedPoint) = gt(FixedPoint(z, 0), w)
(>)(z::FixedPoint, w::Integer) = gt(z, FixedPoint(w, 0))
(>)(z::AbstractFloat, w::FixedPoint) = (z > Float64(w))
(>)(z::FixedPoint, w::AbstractFloat) = (Float64(z) > w)
(>)(z::AbstractString, w::FixedPoint) = gt(FixedPoint(z), w)
(>)(z::FixedPoint, w::AbstractString) = gt(z, FixedPoint(w))

(+)(z::FixedPoint, w::FixedPoint) = add(z, w)
(+)(z::Integer, w::FixedPoint) = add(FixedPoint(z, 0), w)
(+)(z::FixedPoint, w::Integer) = add(z, FixedPoint(w, 0))
(+)(z::AbstractFloat, w::FixedPoint) = add(parse(FixedPoint, string(z)), w)
(+)(z::FixedPoint, w::AbstractFloat) = add(z, parse(FixedPoint, string(w)))
(+)(z::AbstractString, w::FixedPoint) = add(FixedPoint(z), w)
(+)(z::FixedPoint, w::AbstractString) = add(z, FixedPoint(w))

(-)(z::FixedPoint, w::FixedPoint) = sub(z, w)
(-)(z::Integer, w::FixedPoint) = sub(FixedPoint(z, 0), w)
(-)(z::FixedPoint, w::Integer) = sub(z, FixedPoint(w, 0))
(-)(z::AbstractFloat, w::FixedPoint) = sub(parse(FixedPoint, string(z)), w)
(-)(z::FixedPoint, w::AbstractFloat) = sub(z, parse(FixedPoint, string(w)))
(-)(z::AbstractString, w::FixedPoint) = sub(FixedPoint(z), w)
(-)(z::FixedPoint, w::AbstractString) = sub(z, FixedPoint(w))

(*)(z::FixedPoint, w::FixedPoint) = mul(z, w)
(*)(z::Integer, w::FixedPoint) = mul(FixedPoint(z, 0), w)
(*)(z::FixedPoint, w::Integer) = mul(z, FixedPoint(w, 0))
(*)(z::AbstractFloat, w::FixedPoint) = mul(parse(FixedPoint, string(z)), w)
(*)(z::FixedPoint, w::AbstractFloat) = mul(z, parse(FixedPoint, string(w)))
(*)(z::AbstractString, w::FixedPoint) = mul(FixedPoint(z), w)
(*)(z::FixedPoint, w::AbstractString) = mul(z, FixedPoint(w))

(/)(z::FixedPoint, w::FixedPoint) = floatdiv(z, w)
(/)(z::Integer, w::FixedPoint) = floatdiv(FixedPoint(z, 0), w)
(/)(z::FixedPoint, w::Integer) = floatdiv(z, FixedPoint(w, 0))
(/)(z::AbstractFloat, w::FixedPoint) = floatdiv(parse(FixedPoint, string(z)), w)
(/)(z::FixedPoint, w::AbstractFloat) = floatdiv(z, parse(FixedPoint, string(w)))
(/)(z::AbstractString, w::FixedPoint) = floatdiv(FixedPoint(z), w)
(/)(z::FixedPoint, w::AbstractString) = floatdiv(z, FixedPoint(w))

(\)(z::FixedPoint, w::FixedPoint) = invdiv(z, w)
(\)(z::Integer, w::FixedPoint) = invdiv(FixedPoint(z, 0), w)
(\)(z::FixedPoint, w::Integer) = invdiv(z, FixedPoint(w, 0))
(\)(z::AbstractFloat, w::FixedPoint) = invdiv(parse(FixedPoint, string(z)), w)
(\)(z::FixedPoint, w::AbstractFloat) = invdiv(z, parse(FixedPoint, string(w)))
(\)(z::AbstractString, w::FixedPoint) = invdiv(FixedPoint(z), w)
(\)(z::FixedPoint, w::AbstractString) = invdiv(z, FixedPoint(w))

(^)(z::FixedPoint, w::FixedPoint) = pwr(z, w)
(^)(z::Integer, w::FixedPoint) = pwr(FixedPoint(z, 0), w)
(^)(z::FixedPoint, w::Integer) = pwr(z, FixedPoint(w, 0))
(^)(z::AbstractFloat, w::FixedPoint) = pwr(parse(FixedPoint, string(z)), w)
(^)(z::FixedPoint, w::AbstractFloat) = pwr(z, parse(FixedPoint, string(w)))
(^)(z::AbstractString, w::FixedPoint) = pwr(FixedPoint(z), w)
(^)(z::FixedPoint, w::AbstractString) = pwr(z, FixedPoint(w))

(÷)(z::FixedPoint, w::FixedPoint) = intdiv(z, w)
(÷)(z::Integer, w::FixedPoint) = intdiv(FixedPoint(z, 0), w)
(÷)(z::FixedPoint, w::Integer) = intdiv(z, FixedPoint(w, 0))
(÷)(z::AbstractFloat, w::FixedPoint) = intdiv(parse(FixedPoint, string(z)), w)
(÷)(z::FixedPoint, w::AbstractFloat) = intdiv(z, parse(FixedPoint, string(w)))
(÷)(z::AbstractString, w::FixedPoint) = intdiv(FixedPoint(z), w)
(÷)(z::FixedPoint, w::AbstractString) = intdiv(z, FixedPoint(w))

(%)(z::FixedPoint, w::FixedPoint) = rem(z, w)
(%)(z::Integer, w::FixedPoint) = rem(FixedPoint(z, 0), w)
(%)(z::FixedPoint, w::Integer) = rem(z, FixedPoint(w, 0))
(%)(z::AbstractFloat, w::FixedPoint) = rem(parse(FixedPoint, string(z)), w)
(%)(z::FixedPoint, w::AbstractFloat) = rem(z, parse(FixedPoint, string(w)))
(%)(z::AbstractString, w::FixedPoint) = rem(FixedPoint(z), w)
(%)(z::FixedPoint, w::AbstractString) = rem(z, FixedPoint(w))

(log)(z::FixedPoint) = (FixedPoint(log(Float64(z)), z.precision))
(log)(b::FixedPoint, z::FixedPoint) = (FixedPoint(log(Float64(b), Float64(z)), maxprecision(b, z)))
(log)(b::Number, z::FixedPoint) = (FixedPoint(log(b, Float64(z)), z.precision))
(log)(b::FixedPoint, z::Number) = (FixedPoint(log(Float64(b), z), z.precision))
(log10)(z::FixedPoint) = (FixedPoint(log10(Float64(z)), z.precision))
(log2)(z::FixedPoint) = (FixedPoint(log2(Float64(z)), z.precision))
(log1p)(z::FixedPoint) = (FixedPoint(log1p(Float64(z)), z.precision))

(exp)(z::FixedPoint) = (FixedPoint(exp(Float64(z)), z.precision))
(exp2)(z::FixedPoint) = (FixedPoint(exp2(Float64(z)), z.precision))
(exp10)(z::FixedPoint) = (FixedPoint(exp10(Float64(z)), z.precision))

(√)(z::FixedPoint) = (FixedPoint(√(Float64(z)), z.precision))
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

(atan)(z::FixedPoint) = (FixedPoint(atan(Float64(z)), z.precision))
(atan)(z::FixedPoint, w::FixedPoint) = (FixedPoint(atan(Float64(z), Float64(w)), maxprecision(z, w)))
(atan)(z::FixedPoint, w::Number) = (FixedPoint(atan(Float64(z), w), z.precision))
(atan)(z::Number, w::FixedPoint) = (FixedPoint(atan(z, Float64(w)), x.precision))
(atand)(z::FixedPoint) = (FixedPoint(atand(Float64(z)), z.precision))
(atanh)(z::FixedPoint) = (FixedPoint(atanh(Float64(z)), z.precision))

(sec)(z::FixedPoint) = (FixedPoint(sec(Float64(z)), z.precision))
(secd)(z::FixedPoint) = (FixedPoint(secd(Float64(z)), z.precision))
(sech)(z::FixedPoint) = (FixedPoint(sech(Float64(z)), z.precision))

(csc)(z::FixedPoint) = (FixedPoint(csc(Float64(z)), z.precision))
(cscd)(z::FixedPoint) = (FixedPoint(cscd(Float64(z)), z.precision))
(csch)(z::FixedPoint) = (FixedPoint(csch(Float64(z)), z.precision))

(cot)(z::FixedPoint) = (FixedPoint(cot(Float64(z)), z.precision))
(cotd)(z::FixedPoint) = (FixedPoint(cotd(Float64(z)), z.precision))

(asec)(z::FixedPoint) = (FixedPoint(asec(Float64(z)), z.precision))
(asecd)(z::FixedPoint) = (FixedPoint(asecd(Float64(z)), z.precision))
(asech)(z::FixedPoint) = (FixedPoint(asech(Float64(z)), z.precision))

(acsc)(z::FixedPoint) = (FixedPoint(acsc(Float64(z)), z.precision))
(acscd)(z::FixedPoint) = (FixedPoint(acscd(Float64(z)), z.precision))
(acsch)(z::FixedPoint) = (FixedPoint(acsch(Float64(z)), z.precision))

(acot)(z::FixedPoint) = (FixedPoint(acot(Float64(z)), z.precision))
(acotd)(z::FixedPoint) = (FixedPoint(acotd(Float64(z)), z.precision))
(acoth)(z::FixedPoint) = (FixedPoint(acoth(Float64(z)), z.precision))

(asin)(z::FixedPoint) = (FixedPoint(asin(Float64(z)), z.precision))
(asind)(z::FixedPoint) = (FixedPoint(asind(Float64(z)), z.precision))
(asinh)(z::FixedPoint) = (FixedPoint(asinh(Float64(z)), z.precision))

(acos)(z::FixedPoint) = (FixedPoint(acos(Float64(z)), z.precision))
(acosd)(z::FixedPoint) = (FixedPoint(acosd(Float64(z)), z.precision))
(acosh)(z::FixedPoint) = (FixedPoint(acosh(Float64(z)), z.precision))

(deg2rad)(z::FixedPoint) = (FixedPoint(deg2rad(Float64(z)), z.precision))
(rad2deg)(z::FixedPoint) = (FixedPoint(rad2deg(Float64(z)), z.precision))

(hypot)(z::FixedPoint, w::FixedPoint) = (FixedPoint(hypot(Float64(z), Float64(w)), maxprecision(z, w)))
(hypot)(z::FixedPoint, w::Number) = (FixedPoint(hypot(Float64(z), w), z.precision))
(hypot)(z::Number, w::FixedPoint) = (FixedPoint(hypot(z, Float64(w)), w.precision))

(frexp)(z::FixedPoint) = (FixedPoint(frexp(Float64(z)), z.precision))

(ldexp)(z::FixedPoint, w::FixedPoint) = (FixedPoint(ldexp(Float64(z), Float64(w)), maxprecision(z, w)))

(-)(z::FixedPoint) = (FixedPoint(-(z.value), z.precision))
(+)(z::FixedPoint) = (FixedPoint(+(z.value), z.precision))

(ispow2)(z::FixedPoint) = (FixedPoint(ispow2(Float64(z)), z.precision))

(prevpow)(z::FixedPoint, w::FixedPoint) = (FixedPoint(prevpow(Float64(z), Float64(w)), maxprecision(z, w)))
(prevpow)(z::FixedPoint, w::Number) = (FixedPoint(prevpow(Float64(z), w), z.precision))
(prevpow)(z::Number, w::FixedPoint) = (FixedPoint(prevpow(z, Float64(w)), w.precision))

(rem2pi)(z::FixedPoint,r::RoundingMode) = (FixedPoint(rem2pi(Float64(z),r),z.precision))
