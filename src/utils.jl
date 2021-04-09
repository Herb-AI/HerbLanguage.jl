
"Check if a teerm is ground (no variables)"
is_ground(t::Term) = error("Not implemented.")
is_ground(c::Constant) = true
is_ground(v::Var) = false
is_ground(l::Structure) = all(is_ground(e) for e in l.arguments)
is_ground(l::Literal) = all(is_ground(a) for a in l.arguments)
is_ground(n::Negation) = is_ground(n.literal)
is_ground(c::Conj) = all(is_ground(e) for e in c.elements)
is_ground(cl::Clause) = is_ground(cl.head) && is_ground(c.body)



"Get all vars in a term"
get_vars(t::Term) = error("Not implemented.")
get_vars(t::Const) = Set{Variable}()
get_vars(t::Var) = Set{Variable}([t])
get_vars(s::Structure) = union((get_vars(t) for t in s.arguments)...)
get_vars(l::Literal) = union((get_vars(t) for t in l.arguments)...)
get_vars(n::Negation) = get_vars(n.literal)
get_vars(c::Conj) = union((get_vars(e) for e in c.elements)...)
get_vars(cl::Clause) = union(get_vars(cl.head), get_vars(cl.body))



