module CIndices

# Courtesy of the fantastique Willow Ahrens
struct Cindex{T} <: Integer
    val::T
    Cindex{T}(i, b::Bool=true) where {T} = new{T}(T(i) - b)
    Cindex{T}(i::Cindex{T}) where {T} = i
end

cindex_types = [Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128, BigInt]
for S in cindex_types
    @eval begin
        @inline Base.promote_rule(::Type{Cindex{T}}, ::Type{$S}) where {T} = promote_type(T, $S)
        Base.convert(::Type{Cindex{T}}, i::$S) where {T} = Cindex(convert(T, i))
        Cindex(i::$S) = Cindex{$S}(i)
        (::Type{$S})(i::Cindex{T}) where {T} = convert($S, i.val + true)
        Base.convert(::Type{$S}, i::Cindex) = convert($S, i.val + true)
        @inline Base.:(<<)(a::Cindex{T}, b::$S) where {T} = T(a) << b
    end
end
for S in [Float32, Float64]
    @eval begin
        @inline Base.promote_rule(::Type{Cindex{T}}, ::Type{$S}) where {T} = Cindex{promote_type(T, $S)}
        (::Type{$S})(i::Cindex{T}) where {T} = convert($S, i.val + true)
    end
end
Base.promote_rule(::Type{Cindex{T}}, ::Type{Cindex{S}}) where {T, S} = promote_type(T, S)
Base.convert(::Type{Cindex{T}}, i::Cindex) where {T} = Cindex{T}(convert(T, i.val), false)
Base.hash(x::Cindex, h::UInt) = hash(typeof(x), hash(x.val, h))

for op in [:*, :+, :-, :min, :max]
    @eval @inline Base.$op(a::Cindex{T}, b::Cindex{T}) where {T} = Cindex($op(T(a), T(b)))
end

for op in [:*, :+, :-, :min, :max]
    @eval @inline Base.$op(a::Cindex{T}) where {T} = Cindex($op(T(a)))
end

for op in [:<, :<=, :isless]
    @eval @inline Base.$op(a::Cindex{T}, b::Cindex{T}) where {T} = $op(T(a), T(b))
end

for op in [:typemin, :typemax]
    @eval @inline Base.$op(::Type{Cindex{T}}) where {T} = Base.$op(T)
end

end
