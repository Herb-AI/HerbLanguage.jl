
"Generic representation of type"
struct Type 
    name::String
end

abstract type Term end 

"Structure representing constants defined by name and type" 
struct Constant <: Term
    name::String
    type::Type
end



"Structure representing variables defined by name and type"
struct Variable <: Term
    name::String
    type::Type
end


"Structure representing functor defined by name, arity, and argument types"
struct Functor <: Term
    name::String
    arity::Int
end


struct Structure <: Term
    functor::Functor
    arguments::Vector{Union{Term,Integer,Float32}}

    Structure(x,y) = length(y) == x.arity ? new(x,y) : error("number of given arguments does not match; given $(size(y)), required $(x.arity) ")
end


" Structure representing list defined by its elements"
struct List <: Term
    elements::Vector{Union{Term,Integer,Float32}}
end

"Structure representing Pair defined by its elements"
struct LPair <: Term
    head::Union{Term,Int,Float32}
    tail::Term
end

"Structure representing predicates defined by name, arity and argument types"
struct Predicate
    name::String
    arity::Int
    argument_types::Vector{Type}
end




abstract type Formula end

"Structure representing literals"
struct Literal <: Formula
    predicate::Predicate
    arguments::Vector{Term}

    Literal(x,y) = length(arguments) == x.arity ? new(x,y) : error("Number of arguments doesn't match; required $(predicate.arity), given $(size(y))")
end

"Structure representing negation"
struct Negation <: Formula
    literal::Literal
end

"Structure representing conjuncions/body of a clause"
struct Conj <: Formula
    elements::Vector{Union{Literal,Negation}}
end

"Structure representing clauses defined by head and body"
struct Clause <: Formula
    head::Literal
    body::Conj
end

"Structure representing disjunction"
struct Disjunction <: Formula
    clauses::Vector{Clause}
end

"Structure representing recursions"
struct Recursion <: Formula
    clauses::Vector{Clause}
end

"Structure representing a program"
struct Program
    clauses::Vector{Clause}
end


