# CIndices

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaSparse.github.io/CIndices.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSparse.github.io/CIndices.jl/dev/)
[![Build Status](https://github.com/JuliaSparse/CIndices.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSparse/CIndices.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia, Matlab, etc. index arrays [starting at
1](https://docs.julialang.org/en/v1/devdocs/offset-arrays/). C, python, etc.
index starting at 0. In a dense array, we can simply subtract one from the
index, and in fact, this is what Julia will does under the hood when you pass a
vector [between C to
Julia](https://docs.julialang.org/en/v1/manual/embedding/#Working-with-Arrays). 

However, for sparse array formats, it's not just a matter of subtracting one
from the index, as the internal lists of indices, positions, etc all start from
zero as well. To remedy the situation, this package exports a handy zero-indexed integer
type called `CIndex`. The internal representation of `CIndex` is one less than the
value it represents, and we can use `CIndex` as the index or position type of
a sparse array to represent arrays in other languages.

For example, if `idx_c`, `ptr_c`, and `val` are the internal arrays of a CSC
matrix in a zero-indexed language, we can represent that matrix as a one-indexed
Cindex array without copying by calling
```julia
julia> m = 4; n = 3; ptr_c = [0, 3, 3, 5]; idx_c = [1, 2, 3, 0, 2]; val = [1.1, 2.2, 3.3, 4.4, 5.5];

julia> ptr_jl = unsafe_wrap(Array, reinterpret(Ptr{CIndex{Int}}, pointer(ptr_c)), length(ptr_c); own = false)
4-element Vector{CIndex{Int64}}:
 CIndex{Int64}(0)
 CIndex{Int64}(3)
 CIndex{Int64}(3)
 CIndex{Int64}(5)

julia> idx_jl = unsafe_wrap(Array, reinterpret(Ptr{CIndex{Int}}, pointer(idx_c)), length(idx_c); own = false)
5-element Vector{CIndex{Int64}}:
 CIndex{Int64}(1)
 CIndex{Int64}(2)
 CIndex{Int64}(3)
 CIndex{Int64}(0)
 CIndex{Int64}(2)

julia> A = SparseMatrixCSC{Float64, CIndex{Int}}(m, n, ptr_jl, idx_jl, val)
4×3 SparseMatrixCSC{Float64, CIndex{Int64}} with 5 stored entries:
  ⋅    ⋅   4.4
 1.1   ⋅    ⋅ 
 2.2   ⋅   5.5
 3.3   ⋅    ⋅ 
```