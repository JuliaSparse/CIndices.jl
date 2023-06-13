module CIndices

export CIndex

# Courtesy of the fantastique Willow Ahrens
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
    print(io, get(io, :typeinfo, Any) === CIndex{T} ? c.val : c)
end
