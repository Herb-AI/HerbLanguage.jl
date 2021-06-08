
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
    arguments::Vector{Union{Term,Integer,Float64}}

    #Structure(x,y) = length(y) == x.arity ? new(x,y) : error("number of given arguments does not match; given $(size(y)), required $(x.arity) ")
end


" Structure representing list defined by its elements"
struct List <: Term
    elements::Vector{Union{Term,Int64,Float64}}
end

"Structure representing Pair defined by its elements"
struct LPair <: Term
    head::Union{Term,Int64,Float64}
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
    arguments::Vector{Union{Term,Int64,Float64}}

    # Literal(x,y) = length(arguments) == x.arity ? new(x,y) : error("Number of arguments doesn't match; required $(predicate.arity), given $(size(y))")
end

"Structure representing a proposition"
struct Proposition <: Formula
    name::String
end

"Structure representing negation"
struct Negation <: Formula
    literal::Union{Literal,Proposition}
end

"Structure representing conjuncions/body of a clause"
struct Conj <: Formula
    elements::Vector{Union{Literal,Negation,Proposition}}
end

"Structure representing clauses defined by head and body"
struct Clause <: Formula
    head::Union{Literal,Proposition}
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
    clauses::Vector{Formula}
end



"""
    Comparisons
"""
Base.:(==)(term1::Constant,term2::Constant) = term1.name == term2.name && term1.type == term2.type
Base.:(==)(prop1::Proposition, prop2::Proposition) = prop1.name == prop2.name
Base.:(==)(type1::Type, type2::Type) = type1.name == type2.name
Base.:(==)(term1::Variable, term2::Variable) = term1.name == term2.name && term1.type == term2.type
Base.:(==)(term1::Structure, term2::Structure) = term1.functor == term2.functor && term1.arguments == term2.arguments
Base.:(==)(literal1::Literal, literal2::Literal) = literal1.predicate == literal2.predicate && length(literal1.arguments) == length(literal2.arguments) && literal1.arguments == literal2.arguments
Base.:(==)(pair1::LPair, pair2::LPair) = pair1.head == pair2.head && pair1.tail == pair2.tail
Base.:(==)(list1::List, list2::List) = length(list1.elements) == length(list2.elements) && list1.elements == list2.elements
Base.:(==)(conj1::Conj, conj2::Conj) = all([t1 == t2 for (t1, t2) in zip(conj1.elements, conj2.elements)])


"""
    Printers 
"""
function Base.show(io::IO, c::Constant)
    print(io, c.name)
end

function Base.show(io::IO, v::Variable)
    print(io, v.name)
end

function Base.show(io::IO, p::Proposition)
    print(io, p.name)
end

function Base.show(io::IO, f::Functor)
    print(io, f.name)
end

function Base.show(io::IO, s::Structure)
    print(io, s.functor.name, "(", join([repr(a) for a in s.arguments], ",")..., ")")
end

function Base.show(io::IO, l::List)
    print(io, "[", join([repr(a) for a in l.elements], ",")..., "]")
end

function Base.show(io::IO, p::LPair)
    print(io, "[", repr(l.head), " | ", repr(l.tail), "]")
end

function Base.show(io::IO, p::Predicate)
    print(io, p.name)
end

function Base.show(io::IO, l::Literal)
    print(io, l.predicate.name, "(", join([repr(a) for a in l.arguments], ",")..., ")")
end

function Base.show(io::IO, n::Negation)
    print(io, "\\+ ", repr(n.literal))
end

function Base.show(io::IO, cl::Clause)
    print(io, repr(cl.head), " :- ", join([repr(a) for a in cl.body.elements], ", ")...)
end

function Base.show(io::IO, d::Disjunction)
    print(io, "Dis{", join([repr(c) for c in d.clauses], "\n")..., "}")
end

function Base.show(io::IO, r::Recursion)
    print(io, "Rec{", join([repr(c) for c in r.clauses], "\n")..., "}")
end

function Base.show(io::IO, p::Program)
    print(io, "{", join([repr(c) for c in p.clauses], "\n")..., "}")
end

