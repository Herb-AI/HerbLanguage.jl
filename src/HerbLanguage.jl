module HerbLanguage

# push!(LOAD_PATH, pwd())

include("structs.jl")
include("context.jl")
include("parse.jl")
include("operators.jl")

export Type, thing, Constant, Variable, Functor, Structure, List, LPair, Predicate, Literal, Negation, Conj, Clause, Disjunction, Recursion, Program
export Context, c_const!, c_var!, c_functor!, c_pred!, c_type!
export parse_prolog, split_compound_args

end
