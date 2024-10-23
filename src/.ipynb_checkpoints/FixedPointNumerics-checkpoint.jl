module FixedPointNumerics

import Base.==, Base.>=, Base.<=, Base.>, Base.<, Base.+, Base.-, Base.*, Base./, Base.^, Base.÷, Base.\, Base.%
import Base.show, Base.cos, Base.log, Base.log10, Base.log2, Base.sqrt, Base.exp, Base.exp2, Base.exp10, Base.div
import Base.round, Base.RoundingMode, Base.parse

export FixedPoint, scale
export ==, >=, <=, >, <, +, -, *, /, ^, ÷, \, %
export show, cos, log, log10, log2, sqrt, exp, exp2, exp10, div
export round, parse

mutable struct FixedPoint{V<:Integer,P<:Integer} <: Real
    value::V
    precision::P

    function FixedPoint{T,A}(v::T, p:P) where {T<:Integer,A<:Integer}
        new(v, p)
    end

end

FixedPoint(v::T, p:P) where {T<:Int64, P<:Integer} = FixedPoint{T,P}(v, p)

FixedPoint(v::T, p:P) where {T<:Int128, P<:Integer} = FixedPoint{T,P}(v, p)

FixedPoint(v::T, p:P) where {T<:Float64, P<:Integer} = FixedPoint(Int64(trunc(round(v; digits=p) * (10^p))), p)

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
    println(sc)
    println((x.value * y.value) ÷ ((x.value > sc || y.value > sc ? sc : 1)))
    return FixedPoint((x.value * y.value) ÷ ((x.value > sc || y.value > sc ? sc : 1)), x.precision)
end

function div(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    r = ((x.value % y.value) * 10^(x.precision + 1)) ÷ y.value
    if x.precision > 1
        if r % (10^(x.precision - 1)) >= 5
            return FixedPoint((r ÷ (10^(x.precision - 1)) + 1) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        else
            return FixedPoint((r ÷ 10^(x.precision - 1)) + ((x.value ÷ y.value) * 10^(x.precision)), x.precision)
        end
    else
        return FixedPoint(x.value ÷ y.value.x.precision)
    end
end

function rem(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint((x.value % y.value), x.precision)
end

function intdiv(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    return FixedPoint(((x.value ÷ y.value) * 10^(x.precision)), x.precision)
end

function pwr(z::FixedPoint, w::FixedPoint)
    (x, y) = scale(z, w)
    result = round(Float64(x.value / 10^x.precision)^Float64(y.value / 10^y.precision), digits=2)
    return FixedPoint(result, x.precision)
end

function invdiv(z::FixedPoint, w::FixedPoint)
    return div(w, z)
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

function tryparse_internal(s::AbstractString)
    z = parse(::Float64, s)
    n = FixedPoint(0,2)
    if !isNothing(findfirst('e'))
        if findfirst('e',string(z))
            throw(InexactError(:parse, FixedPoint, s))
        end
    else
        decloc = findfirst('.',string(z))
        if isNothing(decloc)
           throw(ArgumentError("Cannot process $(s) a FixedPoint type"))
        else
            n.precision = length(s[decloc+1:end])
            n.value = Int64(z*(10^precision))
        end
    end
    return n
end

parse(::FixedPoint, s::AbstractString; kwargs...) where T<:Real =
    tryparse_internal(s)

(==)(z::FixedPoint, w::FixedPoint) = eq(z, w)
(>=)(z::FixedPoint, w::FixedPoint) = gteq(z, w)
(<=)(z::FixedPoint, w::FixedPoint) = lteq(z, w)
(<)(z::FixedPoint, w::FixedPoint) = lt(z, w)
(>)(z::FixedPoint, w::FixedPoint) = gt(z, w)

(+)(z::FixedPoint, w::FixedPoint) = add(z, w)
(-)(z::FixedPoint, w::FixedPoint) = sub(z, w)
(*)(z::FixedPoint, w::FixedPoint) = mul(z, w)
(/)(z::FixedPoint, w::FixedPoint) = div(z, w)
(/)(z::FixedPoint, w::FixedPoint) = invdiv(z, w)
(^)(z::FixedPoint, w::FixedPoint) = pwr(z, w)
(÷)(z::FixedPoint, w::FixedPoint) = intdiv(z, w)
(%)(z::FixedPoint, w::FixedPoint) = rem(z, w)

(cos)(z::FixedPoint) = (FixedPoint(cos(Float64(z.value) / (10^z.precision)), z.precision))
(log)(z::FixedPoint) = (FixedPoint(log(Float64(z.value) / (10^z.precision)), z.precision))
(log10)(z::FixedPoint) = (FixedPoint(log10(Float64(z.value) / (10^z.precision)), z.precision))
(log2)(z::FixedPoint) = (FixedPoint(log2(Float64(z.value) / (10^z.precision)), z.precision))
(sqrt)(z::FixedPoint) = (FixedPoint(sqrt(Float64(z.value) / (10^z.precision)), z.precision))
(exp)(z::FixedPoint) = (FixedPoint(exp(Float64(z.value) / (10^z.precision)), z.precision))
(exp2)(z::FixedPoint) = (FixedPoint(exp2(Float64(z.value) / (10^z.precision)), z.precision))
(exp10)(z::FixedPoint) = (FixedPoint(exp10(Float64(z.value) / (10^z.precision)), z.precision))

(-)(z::FixedPoint) = (FixedPoint(-(z.value), z.precision))
(+)(z::FixedPoint) = (FixedPoint(+(z.value), z.precision))

end # module FixedPointNumerics
