
abstract type ProbabilisticFormula <: Formula end



struct ProbabilisticLiteral <: ProbabilisticFormula
	prob::Float64
	literal::Union{Literal,Proposition} 
end


struct AnnotatedDisjunction <: ProbabilisticFormula
	heads::Vector{ProbabilisticLiteral}
	body::Union{Conj,Bool}
end



isprobabilisticfact(a::AnnotatedDisjunction) = length(a.heads) == 1 && a.body == true

function Base.show(io::IO, p::ProbabilisticLiteral)
	print(io, p.prob, "::", repr(p.literal))
end

function Base.show(io::IO, ad::AnnotatedDisjunction)
	print(io, join([repr(h) for h in ad.heads], " ; "), " :- ", repr(ad.body))
end





