include("../src/FixedPointNumerics.jl")

using .FixedPointNumerics
using Test

@testset "Fixed Point Numerics Tests" begin

    fp1 = FixedPoint(102, 2)
    fp2 = FixedPoint(1020, 2)
    fp3 = FixedPoint(10020, 3)
    fp4 = FixedPoint(98, 2)
    fp5 = FixedPoint(98, 2)
    fp6 = FixedPoint(10.24, 2)
    fp7 = FixedPoint(15000, 2)
    fp8 = FixedPoint(10000, 2)
    fp9 = FixedPoint(2000, 3)
    fp10 = FixedPoint(2100, 2)
    fp11 = FixedPoint(415, 2)
    fp12 = FixedPoint(415, 1)
    fp13 = FixedPoint(222, 1)
    fp14 = FixedPoint(14.2, 1)
    fp15 = FixedPoint(1.3339, 3)
    fp16 = FixedPoint(1, 1)
    fp17 = FixedPoint(2, 1)

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
    @test 0.98 <= fp5

    @test cos(fp1) == 0.52
    @test sin(fp1) == 0.85
    @test tan(fp1) == 1.63

    @test hypot(fp12, fp13) == round(hypot(41.5, 22.2); digits=1)

    bfp1 = BigFixedPoint(102, 2)
    bfp2 = BigFixedPoint(1020, 2)
    bfp3 = BigFixedPoint(10020, 3)
    bfp4 = BigFixedPoint(98, 2)
    bfp5 = BigFixedPoint(98, 2)
    bfp6 = BigFixedPoint(10.24, 2)
    bfp7 = BigFixedPoint(15000, 2)
    bfp8 = BigFixedPoint(10000, 2)
    bfp9 = BigFixedPoint(2000, 3)
    bfp10 = BigFixedPoint(2100, 2)
    bfp11 = BigFixedPoint(415, 2)
    bfp12 = BigFixedPoint(415, 1)
    bfp13 = BigFixedPoint(222, 1)
    bfp14 = BigFixedPoint(14.2, 1)
    bfp15 = BigFixedPoint(1.3339, 3)
    bfp16 = BigFixedPoint(1, 1)
    bfp17 = BigFixedPoint(2, 1)

    bfp18 = BigFixedPoint(1900719925474099256, 2)

    @test bfp16 + bfp17 == 0.3

    @test bfp2 / bfp1 == 10
    @test bfp2 / 10 == 1.02
    @test 204 / bfp1 == 200

    @test bfp12 ÷ bfp13 == 1
    @test bfp12 ÷ 22.2 == 1
    @test 41.5 ÷ bfp13 == 1

    @test bfp12 + bfp13 == 63.7
    @test bfp12 + 22.2 == 63.7
    @test 41.5 + bfp13 == 63.7

    @test bfp12 - bfp13 == 19.3
    @test bfp12 - 22.2 == 19.3
    @test 41.5 - bfp13 == 19.3

    @test bfp4 * bfp6 == "10.03"
    @test 10.03 == bfp4 * bfp6
    @test bfp4 * 10.24 == "10.03"
    @test 10.24 * bfp4 == "10.03"

    @test bfp2 > bfp1
    @test bfp1 < bfp2
    @test bfp2 >= bfp1
    @test bfp4 >= bfp5
    @test bfp1 <= bfp2
    @test bfp4 <= bfp5

    @test bfp2 > 1.02
    @test 1.02 < bfp2
    @test bfp2 >= 1.02
    @test bfp4 >= 0.98
    @test 1.02 <= bfp2
    @test 0.98 <= bfp5

    @test cos(bfp1) == 0.52
    @test sin(bfp1) == 0.85
    @test tan(bfp1) == 1.63

    @test hypot(bfp12, bfp13) == round(hypot(41.5, 22.2); digits=1)

    @test (bfp18 * bfp18) == BigFixedPoint(BigInt(36127362350942654298385217045397535), 2)

    @test bfp2 > fp1
    @test bfp1 < fp2
    @test bfp2 >= fp1
    @test bfp4 >= fp5
    @test bfp1 <= fp2
    @test bfp4 <= fp5

end