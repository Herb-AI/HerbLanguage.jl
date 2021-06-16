
"Check if a teerm is ground (no variables)"
is_ground(t::Term) = error("Not implemented.")
is_ground(c::Constant) = true
is_ground(v::Variable) = false
is_ground(l::Structure) = all(is_ground(e) for e in l.arguments)
is_ground(l::Literal) = all(is_ground(a) for a in l.arguments)
is_ground(n::Negation) = is_ground(n.literal)
is_ground(c::Conj) = all(is_ground(e) for e in c.elements)
is_ground(cl::Clause) = is_ground(cl.head) && is_ground(c.body)



"Get all vars in a term"
get_vars(t::Term) = error("Not implemented.")
get_vars(t::Constant) = Set{Variable}()
get_vars(t::Variable) = Set{Variable}([t])
get_vars(s::Structure) = union((get_vars(t) for t in s.arguments)...)
get_vars(l::Literal) = union((get_vars(t) for t in l.arguments)...)
get_vars(n::Negation) = get_vars(n.literal)
get_vars(c::Conj) = union((get_vars(e) for e in c.elements)...)
get_vars(cl::Clause) = union(get_vars(cl.head), get_vars(cl.body))


"Get arity"
get_arity(c::Constant) = 1
get_arity(f::Functor) = f.arity
get_arity(p::Predicate) = p.arity
get_arity(s::Structure) = s.functor.arity
get_arity(l::Literal) = l.predicate.arity
get_arity(p::LPair) = 2
get_arity(v::Variable) = error("Cannot determine the arity of a variable")
get_arity(cl::Clause) = error("Cannot determine the arity of a clause")


"get functor name"
get_functor_name(f::Functor) = f.name
get_functor_name(p::Predicate) = p.name
get_functor_name(s::Structure) = s.functor.name
get_functor_name(l::Literal) = l.predicate.name
get_functor_name(c::Constant) = c.name
get_functor_name(v::Variable) = error("Variables do not have functors")
get_functor_name(e::Union{Clause,Conj}) = error("Not implemented")


"substitute variables"
subs(b::Bool, sub::Dict{Variable,Variable}) = b
subs(c::Constant, sub::Dict{Variable,Variable}) = c
subs(v::Variable, sub::Dict{Variable,Variable}) = get(sub, v, v)
subs(s::Structure, sub::Dict{Variable, Variable}) = Structure(s.functor, [subs(t, sub) for t in s.arguments])
subs(p::Proposition, subs::Dict{Variable,Variable}) = p
subs(l::List, sub::Dict{Variable,Variable}) = List([subs(e, sub) for e in l.elements])
subs(p::LPair, sub::Dict{Variable,Variable}) = LPair(subs(p.head, sub), subs(p.tail, sub))
subs(l::Literal, sub::Dict{Variable,Variable}) = Literal(l.predicate, [subs(a, sub) for a in l.arguments])
subs(c::Conj, sub::Dict{Variable, Variable}) = Conj([subs(e, sub) for e in c.elements])
subs(cl::clause, sub::Dict{Variable,Variable}) = Clause(subs(cl.head, sub), subs(cl.body, sub))
