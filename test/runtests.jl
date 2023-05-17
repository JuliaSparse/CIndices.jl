using CIndices
using SparseArrays
using Test

@testset "CIndices.jl" begin
    m = 4; n = 3; ptr_c = [0, 3, 3, 5]; idx_c = [1, 2, 3, 0, 2]; val = [1.1, 2.2, 3.3, 4.4, 5.5];

    ptr_jl = unsafe_wrap(Array, reinterpret(Ptr{CIndex{Int}}, pointer(ptr_c)), length(ptr_c); own = false)

    idx_jl = unsafe_wrap(Array, reinterpret(Ptr{CIndex{Int}}, pointer(idx_c)), length(idx_c); own = false)

    A = SparseMatrixCSC{Float64, CIndex{Int}}(m, n, ptr_jl, idx_jl, val)
    @test A == [
        0.0 0.0 4.4
        1.1 0.0 0.0
        2.2 0.0 5.5
        3.3 0.0 0.0
    ]
end
