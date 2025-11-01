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

@testset "Test for colon" begin
@origin (a=>0, b=>2) function test()
    a = collect(0:10)
    b = collect(1:5)
    
    # Test simple colon range with origin 0
    @test a[0:5] == [0, 1, 2, 3, 4, 5]
    @test a[3:7] == [3, 4, 5, 6, 7]
    @test a[0:10] == collect(0:10)
    
    # Test simple colon range with origin 2
    @test b[2:4] == [1, 2, 3]
    @test b[2:6] == [1, 2, 3, 4, 5]
    
    # Test colon with step (origin 0)
    @test a[0:2:10] == [0, 2, 4, 6, 8, 10]
    @test a[1:2:9] == [1, 3, 5, 7, 9]
    @test a[0:3:9] == [0, 3, 6, 9]
    
    # Test colon with step (origin 2)
    @test b[2:2:6] == [1, 3, 5]
    @test b[3:2:6] == [2, 4]
    
    # Test colon with end (origin 0)
    @test a[0:end] == collect(0:10)
    @test a[5:end] == collect(5:10)
    @test a[8:end] == [8, 9, 10]
    
    # Test colon with end (origin 2)
    @test b[2:end] == [1, 2, 3, 4, 5]
    @test b[4:end] == [3, 4, 5]
    
    # Test colon with step and end
    @test a[0:2:end] == [0, 2, 4, 6, 8, 10]
    @test b[2:2:end] == [1, 3, 5]

    # Test full colon
    @test a[:] == collect(0:10)
    @test b[:] == collect(1:5)

    @test a[0:0] == [0]        # the first element
    @test a[10:10] == [10]     # the last element
    @test b[6:6] == [5]        # 2-origin: the last element
end
test()
end

@testset "Test for 2D arrays" begin
@origin (M=>0, N=>1) function test()
    # Create a 3x4 matrix
    M = [i*10 + j for i in 1:3, j in 1:4]
    N = [i*100 + j for i in 1:4, j in 1:3]
    
    # Test single element access with origin 0
    @test M[0, 0] == 11
    @test M[0, 3] == 14
    @test M[2, 0] == 31
    @test M[2, 3] == 34
    
    # Test single element access with origin 1
    @test N[1, 1] == 101
    @test N[1, 3] == 103
    @test N[4, 1] == 401
    @test N[4, 3] == 403
    
    # Test row slicing with origin 0
    @test M[0, :] == [11, 12, 13, 14]
    @test M[1, :] == [21, 22, 23, 24]
    @test M[2, :] == [31, 32, 33, 34]
    
    # Test column slicing with origin 0
    @test M[:, 0] == [11, 21, 31]
    @test M[:, 1] == [12, 22, 32]
    
    # Test range slicing with origin 0
    @test M[0:1, 0:1] == [11 12; 21 22]
    @test M[1:2, 2:3] == [23 24; 33 34]
    
    # Test range slicing with origin 1
    @test N[1:2, 1:2] == [101 102; 201 202]
    @test N[3:4, 2:3] == [302 303; 402 403]
    
    # Test with end keyword
    @test M[0, 0:end] == [11, 12, 13, 14]
    @test M[0:end, 0] == [11, 21, 31]
    @test M[1:end, 1:end] == [22 23 24; 32 33 34]
    
    @test N[1:end, 1] == [101, 201, 301, 401]
    @test N[2, 1:end] == [201, 202, 203]
end
test()
end

@testset "Test for 2D arrays with same origin" begin
@origin A=>0 function test()
    # Create a 4x5 matrix
    A = [i*10 + j for i in 1:4, j in 1:5]
    
    # Test that both dimensions use origin 0
    @test A[0, 0] == 11  # top-left
    @test A[0, 4] == 15  # top-right
    @test A[3, 0] == 41  # bottom-left
    @test A[3, 4] == 45  # bottom-right
    
    # Test middle elements
    @test A[1, 2] == 23
    @test A[2, 3] == 34
    
    # Test slicing with both dimensions
    @test A[0:2, 0:2] == [11 12 13; 21 22 23; 31 32 33]
    @test A[1:3, 2:4] == [23 24 25; 33 34 35; 43 44 45]
    
    # Test full slices
    @test size(A[0:end, 0:end]) == (4, 5)
    @test A[0:end, 2] == [13, 23, 33, 43]
    @test A[2, 0:end] == [31, 32, 33, 34, 35]
end
test()
end
