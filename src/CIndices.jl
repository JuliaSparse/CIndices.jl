module CIndices

export CIndex

# Courtesy of the fantastique Willow Ahrens
"""
    CIndex{T}(i)
    CIndex(i::T)
    CIndex{T}(j, false)

A zero-based integer type. A `CIndex` represents the one-based value `i`, but
stores `i - 1` in its single field of type `T`, so it has the same bits as the
zero-based index a C library would use for the same position. `CIndex{T}(j, false)`
builds a `CIndex` from a raw zero-based value `j`.

Use `CIndex{T}` as the index or position type of an array structure (e.g. the
`colptr` and `rowval` arrays of a `SparseMatrixCSC`) to wrap zero-based data
from another language without copying or shifting it.

Converting a `CIndex` to an ordinary integer gives the one-based value it represents.
Arithmetic and comparison between two `CIndex{T}`s act on those values and return a
`CIndex{T}` (or `Bool`); mixing a `CIndex` with another integer type promotes to that
integer type.

# Examples
```jldoctest
julia> i = CIndex(1)
CIndex{Int64}(1)

julia> i.val
0

julia> Int(i)
1

julia> CIndex{Int32}(0, false)
CIndex{Int32}(1)

julia> CIndex(3) + CIndex(4)
CIndex{Int64}(7)

julia> CIndex(2) + 1
3

julia> reinterpret(CIndex{Int}, [0, 1, 2])
3-element reinterpret(CIndex{Int64}, ::Vector{Int64}):
 1
 2
 3
```
"""
struct CIndex{T} <: Integer
    val::T
    CIndex{T}(i, b::Bool=true) where {T} = new{T}(T(i) - b)
    CIndex{T}(i::CIndex{T}) where {T} = i
end

cindex_types = [Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128, BigInt]
for S in cindex_types
    @eval begin
        @inline Base.promote_rule(::Type{CIndex{T}}, ::Type{$S}) where {T} = promote_type(T, $S)
        Base.convert(::Type{CIndex{T}}, i::$S) where {T} = CIndex(convert(T, i))
        CIndex(i::$S) = CIndex{$S}(i)
        (::Type{$S})(i::CIndex{T}) where {T} = convert($S, i.val + true)
        Base.convert(::Type{$S}, i::CIndex) = convert($S, i.val + true)
        @inline Base.:(<<)(a::CIndex{T}, b::$S) where {T} = T(a) << b
    end
end
for S in [Float32, Float64]
    @eval begin
        @inline Base.promote_rule(::Type{CIndex{T}}, ::Type{$S}) where {T} = CIndex{promote_type(T, $S)}
        (::Type{$S})(i::CIndex{T}) where {T} = convert($S, i.val + true)
    end
end
Base.promote_rule(::Type{CIndex{T}}, ::Type{CIndex{S}}) where {T, S} = promote_type(T, S)
Base.convert(::Type{CIndex{T}}, i::CIndex) where {T} = CIndex{T}(convert(T, i.val), false)
Base.hash(x::CIndex, h::UInt) = hash(typeof(x), hash(x.val, h))
Base.eltype(::Type{CIndex{T}}) where T = T
for op in [:*, :+, :-, :min, :max]
    @eval @inline Base.$op(a::CIndex{T}, b::CIndex{T}) where {T} = CIndex($op(T(a), T(b)))
end

for op in [:*, :+, :-, :min, :max]
    @eval @inline Base.$op(a::CIndex{T}) where {T} = CIndex($op(T(a)))
end

for op in [:<, :<=, :isless]
    @eval @inline Base.$op(a::CIndex{T}, b::CIndex{T}) where {T} = $op(T(a), T(b))
end

for op in [:typemin, :typemax]
    @eval @inline Base.$op(::Type{CIndex{T}}) where {T} = Base.$op(T)
end

Base.unsafe_convert(::Ptr{T}, a::Vector{CIndex{T}}) where T = Ptr{T}(pointer(a))
Base.show(io::IO, ::MIME"text/plain", c::CIndex{T}) where T = 
    print(io, get(io, :typeinfo, Any) === CIndex{T} ? c.val + 1 : "CIndex{$T}($(c.val + 1))")
Base.show(io::IO, c::CIndex{T}) where T = 
    print(io, get(io, :typeinfo, Any) === CIndex{T} ? c.val + 1 : "CIndex{$T}($(c.val + 1))")

end
