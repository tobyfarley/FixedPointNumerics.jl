# FixedPointNumerics

This package implements fixed point numbers using integers. Largly undocumented! It is alpha quality at the moment.

Basically 

    FixPoint(z::Integer,w::Integer) will create a fixed point number with the decimal point place w places from the right

    FixePoint(z::AbstractFloat, w::Integer) will create fixed point number rounded to w digits with w places

    parse(::FixedPoint, s::String) will attempt to parse a string finding the decimal point and creating a fixed point number
        with the number of digits past the decimal point as the number of places


Version 0.0.1
