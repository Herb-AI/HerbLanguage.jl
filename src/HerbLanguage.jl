module HerbLanguage

using Base: Symbol, vect, tail, Callable, uv_status_string, replaceuserpath, RangeStepRegular
include("structs.jl")
include("context.jl")
include("parse.jl")
include("operators.jl")
include("utils.jl")
include("structs-prob.jl")

export Type, thing, Constant, Variable, Functor, Structure, List, LPair, Predicate, Literal, Proposition, Negation, Conj, Clause, Disjunction, Recursion, Program
export Context, c_const!, c_const, c_var!, c_var, c_functor!, c_functor, c_pred!, c_pred, c_type!, c_type!, c_prop!, c_prop
export from_string, @prolog, @problog, expr_to_prolog, expr_to_problog
export is_ground, get_vars, get_arity, get_functor_name, subs
export ProbabilisticLiteral, AnnotatedDisjunction 

end # module
