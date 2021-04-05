
# easier creation of atoms

function (p::Predicate)(args::Vararg{Term})
    Literal(p, args)
end

function (f::Functor)(args::Vararg{Term})
    Structure(f, args)
end

# \+(literal::Literal) = Negation(literal)

Base.:!(literal::Literal) = Negation(literal)


# easier syntax for constructing clauses
function Base.:&(left::Union{Literal,Negation}, right::Union{Negation,Literal}) 
    Conj([left, right])
end

function Base.:&(left::Conj, right::Union{Literal,Negation})
    Conj(vcat(left, right))
end

function Base.:(<=)(left::Literal, right::Conj)
    Clause(left, right)
end

function Base.:(<=)(left::Literal, right::Union{Literal,Negation})
    Clause(left, Conj(right))
end

