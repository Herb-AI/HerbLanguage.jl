
"Context manager to reduce memory usage"
mutable struct Context
    predicates::Dict{Int,Dict{String,Predicate}}
    constants::Dict{Type,Dict{String,Constant}}
    variables::Dict{Type,Dict{String,Variable}}
    functors::Dict{Int,Dict{String,Functor}}
    types::Dict{String,Type}
    propositions::Dict{String,Proposition}

    function Context()
        return new(Dict(), Dict(), Dict(), Dict(), Dict(), Dict())
    end
end

const global_context = Context()




"constructs a new type within context"
function c_type!(name::String, context::Context)
    if !haskey(context.types, name)
        context.types[name] = HerbLanguage.Type(name)
    end

    context.types[name]
end

c_type(name::String) = c_type!(name, global_context)




"Creates constant within the context"
function c_const!(name::String, type::Type, context::Context)
    if !haskey(context.constants, type)
        context.constants[type] = Dict{String, Constant}()
    end

    if !haskey(context.constants[type], name)
        context.constants[type][name] = Constant(name, type)
    end

    context.constants[type][name]
end

c_const(name::String, type::Type) = c_const!(name, type, global_context)
c_const!(name::String, context::Context) = c_const!(name, c_type!("thing", context), context)
c_const(name::String) = c_const!(name, c_type(name), global_context)




"Creates a variable within a context"
function c_var!(name::String, type::Type, context::Context)
    if !haskey(context.variables, type)
        context.variables[type] = Dict{String,Variable}()
    end

    if !haskey(context.variables[type], name)
        context.variables[type][name] = Variable(name, type)
    end

    context.variables[type][name]
end

c_var(name::String, type::String) = c_var!(name, type, global_context)
c_var!(name::String, context::Context) = c_var!(name, c_type!("thing", context), context)
c_var(name::String) = c_var!(name, c_type("thing"), global_context)





"Constructs a predicate within context"
function c_pred!(name::String, arity::Int, arg_types::Vector{Type}, context::Context)
    if !haskey(context.predicates, arity)
        context.predicates[arity] = Dict{String,Predicate}()
    end

    if !haskey(context.predicates[arity], name)
        context.predicates[arity][name] = Predicate(name, arity, arg_types)
    end

    context.predicates[arity][name]
end

c_pred!(name::String, arity::Int, context::Context) = c_pred!(name, arity, fill(c_type!("thing", context), (arity,)), context)
c_pred!(name::String, arg_types::Vector{Type}, context::Context) = c_pred!(name, length(arg_types), arg_types, context)
c_pred(name::String, arity::Int) = c_pred!(name, arity, fill(c_type("thing"), (arity,)), global_context)
c_pred(name::String, arg_types::Vector{Type}) = c_pred!(name, length(arg_types), arg_types, global_context)




"Construct functor"
function c_functor!(name::String, arity::Int, context::Context)
    if !haskey(context.functors, arity)
        context.functors[arity] = Dict{String, Functor}()
    end

    if !haskey(context.functors[arity], name)
        context.functors[arity][name] = Functor(name, arity)
    end

    context.functors[arity][name]
end

c_functor(name::String, arity::Int) = c_functor!(name, arity, global_context)





"Construct proposition"
function c_prop!(name::String, context::Context)
    if !haskey(context.propositions, name)
        context.propositions[name] = Proposition(name)
    end

    context.propositions[name]
end

c_prop(name) = c_prop!(name, global_context)