include("../src/FixedPointNumerics.jl")

using .FixedPointNumerics
using Test

@testset "Fixed Point Numerics Tests" begin

    fp1 = FixedPoint(102,2)
    fp2 = FixedPoint(1020,2)
    fp3 = FixedPoint(10020,3)
    fp4 = FixedPoint(98,2)
    fp5 = FixedPoint(98,2)
    fp6 = FixedPoint(10.24,2)
    fp7 = FixedPoint(15000,2)
    fp8 = FixedPoint(10000,2)
    fp9 = FixedPoint(2000,3)
    fp10 = FixedPoint(2100,2)
    fp11 = FixedPoint(415,2)
    fp12 = FixedPoint(415,1)
    fp13 = FixedPoint(222,1)
    fp14 = FixedPoint(14.2,1)
    fp15 = FixedPoint(1.3339,3)
    fp16 = FixedPoint(1,1)
    fp17 = FixedPoint(2,1)

    @test fp16 + fp17 == 0.3

    @test fp2 / fp1 == 10
    @test fp2 / 10 == 1.02
    @test 204 / fp1 == 200

    @test fp12 ÷ fp13 == 1
    @test fp12 ÷ 22.2 == 1
    @test 41.5 ÷ fp13 == 1

    @test fp12 + fp13 == 63.7
    @test fp12 + 22.2 == 63.7
    @test 41.5 + fp13 == 63.7

    @test fp12 - fp13 == 19.3
    @test fp12 - 22.2 == 19.3
    @test 41.5 - fp13 == 19.3

    @test fp4 * fp6 == 10.03
    @test 10.03 == fp4 * fp6
    @test fp4 * 10.24 == 10.03
    @test 10.24 * fp4 == 10.03

    @test fp2 > fp1
    @test fp1 < fp2
    @test fp2 >= fp1
    @test fp4 >= fp5
    @test fp1 <= fp2
    @test fp4 <= fp5

    @test fp2 > 1.02
    @test 1.02 < fp2
    @test fp2 >= 1.02
    @test fp4 >= 0.98
    @test 1.02 <= fp2
    @test .98 <= fp5

    @test cos(fp1) == 0.52
    @test sin(fp1) == 0.85
    @test tan(fp1) == 1.63

    @test hypot(fp12, fp13) == round(hypot(41.5,22.2);digits=1)

end