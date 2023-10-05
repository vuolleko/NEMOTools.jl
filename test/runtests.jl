using NEMOTools
using Test

@testset "NEMOTools.jl" begin
    # https://julialang.org/contribute/developing_package/#step_4_test_your_package
    @test NEMOTools.min2zero([-2, 3, 0, -10, 10]) == [0, 3, 0, 0, 10]
end
