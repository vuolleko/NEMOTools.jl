using NEMOTools
using Test

@test NEMOTools.min2zero([-2, 3, 0, -10, 10]) == [0, 3, 0, 0, 10]

@testset "NEMOTools.thinner" begin
    row = [1, 2, 3, 4, 5, 6]'
    A = vcat(row, 10row, 100row, 1000row)
    @test NEMOTools.thinner(row', 3) == [1, 4]
    @test NEMOTools.thinner(A, 3) == [1 4; 1000 4000]
    @test NEMOTools.thinner(A, 2, 3) == [1 4; 100 400]
    @test_throws AssertionError NEMOTools.thinner(A, 1, 2, 3)
end
