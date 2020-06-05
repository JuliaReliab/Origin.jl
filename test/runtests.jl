using Origin
using Test

@testset "Test for plain" begin
@origin (a=>0, b=>2) function test()
    a = collect(0:10)
    b = collect(1:5)
    @test a[0] == 0
    @test a[10] == 10
    @test b[2] == 1
    @test b[4] == 3
    @test b[end] == 5
    @test b[2:end] == [1, 2, 3, 4, 5]
    @test b[a[5]] == 4
end
test()
end

@testset "Test for nesting" begin
@origin (a=>0, b=>2) function test()
    a = collect(0:10)
    b = collect(1:5)
    @test a[0] == 0
    @test b[2] == 1
    @origin a=>100 begin
        @test a[101] == 1
    end
end
test()
end

@testset "Test for eachindex" begin
@origin (a=>0, b=>2) function test()
    a = collect(0:10)
    for i = eachindex(a)
        a[i] = i
    end
end
@test_throws BoundsError test()
end

@testset "Test for eachindex2" begin
@origin (b=>2) function test()
    a = collect(0:10)
    for i = eachindex(a)
        a[i] = i
    end
    a
end
a = test()
for i = eachindex(a)
    @test a[i] == i
end
end
