# FixedPointNumerics

This package implements fixed point numbers using integers. Feature complete as an intial version. 

Basically 

    FixPoint(z::Integer,w::Integer) will create a fixed point number with the decimal point place w places from the right

    FixePoint(z::AbstractFloat, w::Integer) will create fixed point number rounded to w digits with w places

    parse(::FixedPoint, s::String) will attempt to parse a string finding the decimal point and creating a fixed point number
        with the number of digits past the decimal point as the number of places

    There is a BigFixedPoint with similar interface

Basic math operations and some higher math functionality availiable. Every equation will widen a fixed point number to the 
largest precision of any fixed point number in the equation. For example, multiplying a number of two decimal places by one of four places
will produce a four place number regardless of the result. A conversion to float and back to fixed point is done when calling
higher math functions. With single parameter math functions (ie. sin, cos and tan) the number of decimal places is preserved. 

Version 1.0.0
