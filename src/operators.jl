
# easier creation of atoms

function (p::Predicate)(args::Vararg{Term})
    Literal(p, args)
end

function (f::Functor)(args::Vararg{Term})
    Structure(f, args)
end

# \+(literal::Literal) = Negation(literal)

Base.:!(literal::Literal) = Negation(literal)



"""
    Easier syntax for constructing clauses
"""
function Base.:&(left::Union{Literal,Negation,Proposition}, right::Union{Negation,Literal,Proposition}) 
    Conj([left, right])
end

function Base.:&(left::Conj, right::Union{Literal,Negation,Proposition})
    Conj(vcat(left, right))
end

function Base.:(<=)(left::Union{Literal,Proposition}, right::Conj)
    Clause(left, right)
end

function Base.:(<=)(left::Union{Literal,Proposition}, right::Union{Literal,Negation})
    Clause(left, Conj(right))
end

