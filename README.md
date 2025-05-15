# FixedPointNumerics

This package implements fixed point numbers using integers. Feature complete as an intial version. 

Basically 

    FixPoint(z::Integer,w::Integer) will create a fixed point number with the decimal point place w places from the right

    FixedPoint(z::AbstractFloat, w::Integer) will create fixed point number rounded to w digits with w places

    FixedPoint(v::AbstractString) will try to create a FixedPoint Number from a string using the placing of the decimal point for       precision

    parse(::FixedPoint, s::String) will attempt to parse a string finding the decimal point and creating a fixed point number
        with the number of digits past the decimal point as the number of places

    There is a BigFixedPoint with a similar interface

    Strings can be used in equations where float constants might create inaccuracies due to the nature of floats. 

Basic math operations and some higher math functionality availiable. Every equation will widen a fixed point number to the 
largest precision of any fixed point number in the equation. For example, multiplying a number of two decimal places by one of four places
will produce a four place number regardless of the result. A conversion to float and back to fixed point is done when calling
higher math functions. With single parameter math functions (ie. sin, cos and tan) the number of decimal places is preserved. 

No breaking changes from previous versions

Version 1.0.1
