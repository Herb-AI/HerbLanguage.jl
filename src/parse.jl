
"Splits the given string into arguments"
function split_compound_args(args::String)
    elems = Vector{String}()
    bracket_stack = Vector{Char}() 
    last_index = 1
    ignore = false # for skipping inner parsing of string constants

    for ind = 1:length(args)
        if args[ind] == '\'' || args[ind] == '"'
            # if string constant is found, ignore any inner parsing until  you find closing '/"
            ignore = true
        elseif ignore && (args[ind] == '\'' || args[ind] == '"')
            # found closing '/", start splitting again
            ignore == false
        elseif args[ind] == '[' && !ignore
            # starting a list
            push!(bracket_stack, '[')
        elseif args[ind] == ']' && !ignore && ind != length(args)
            # found end of the list, not as at last character in the string
            elem = pop!(bracket_stack)
            if elem != '['
                error("wrongly formatted string $args")
            end
        elseif args[ind] == '(' && !ignore
            # start processing args of a structure
            push!(bracket_stack, '(')
        elseif args[ind] == ')' && !ignore && ind != length(args)
            # found end of the structure, not at the end of everything
            elem = pop!(bracket_stack)
            if elem != '('
                error("Wrongly formatted string $args")
            end
        elseif args[ind] == ',' && isempty(bracket_stack) && !ignore
            # found end of the argument
            push!(elems, args[last_index:ind-1])
            last_index = ind + 1
        elseif ind == length(args)
            # encountered end
            push!(elems, args[last_index:end])
        end
    end

    elems
end

"""
    converts a string to HerbLanguage

    [A-Z].* || _.*              -> Variable
    [a-z].* || '.*' || ".*"     -> Constant
    functor(args)               -> Structure if start_with_literals=false, otherwise Literal
    [...]                       -> List
    [X|Y]                       -> LPair
    \\+ ...                     -> Negation
"""
function parse_prolog(elem::String; start_with_literals=false)
    elem = String(strip(elem))
    if tryparse(Int,elem) != nothing
        tryparse(Int, elem)
    elseif tryparse(Float32, elem) != nothing
        tryparse(Float32, elem)
    elseif startswith(elem, "[")
        if occursin("|", elem)
            elem = elem[begin+1:end-1]
            separator_index = findfirst(isequal('|'), elem)
            head = elem[begin:separator_index-1]
            tail = elem[separator_index+1:end]
            LPair(parse_prolog(head), parse_prolog(tail))
        else
            args_to_parse = elem[begin+1:end-1]
            parsed_args = split_compound_args(args_to_parse)
            List([parse_prolog(a) for a in parsed_args])
        end
    elseif startswith(elem, "\\+")
        elem = strip(elem[begin+2:end])
        Negation(parse_prolog(elem, start_with_literals=true))
    elseif occursin("(", elem)
        open_bracket = findfirst(isequal('('), elem)
        closed_bracket = findlast(isequal(')'), elem)
        functor_name = elem[begin:open_bracket-1]
        args_to_parse = elem[open_bracket+1:closed_bracket-1]
        parsed_args = split_compound_args(args_to_parse)

        if start_with_literals
            Literal(c_pred(functor_name, length(parsed_args)), [parse_prolog(a) for a in parsed_args])
        else
            Structure(c_functor(functor_name, length(parsed_args)), [parse_prolog(a) for a in parsed_args])
        end
    elseif isuppercase(elem[1]) || startswith(elem, "_") 
        c_var(elem)
    elseif (islowercase(elem[1]) || startswith(elem, "'") || startswith(elem, "\"")) && !start_with_literals
        c_const(elem)
    elseif islowercase(elem[1]) && start_with_literals
        c_prop(elem)
    else
        throw(DomainError(elem, "don't know how to convert it"))
    end
end

"""
    Parses a clause from a string
"""
function parse_clause(elem::String)
    sep = findfirst(":-", elem)
    head = elem[begin:sep[begin]-1]
    body = split_compound_args(elem[sep[begin+1]+1:end])
    Clause(parse_prolog(head, start_with_literals=true), Conj([parse_prolog(l, start_with_literals=true) for l in body]))
end

"""
    Parses a Prolog expression from a string
    asssumes a single clause

    base=true the first encounter of a compound structure is deemed Literal; otherwise Structure
              0-arity structures are interpreted as propositions; otherwise constants
"""
function from_string(elem::String; base=true)
    if occursin(":-", elem)
        parse_clause(elem)
    else
        parse_prolog(elem, start_with_literals=base)
    end
end


function macro_parse_term(expr)
    if isa(expr, Number)
        # numbers remain numbers
        return :($expr)
    elseif isa(expr, Symbol)
        if isuppercase(string(expr)[begin]) || string(expr)[1] == "_"
            # uppercased symbols are variables
            v = c_var(string(expr))
            return :($v)
        else
            # lowercase symbols are constants
            c = c_const(string(expr))
            return :($c)
        end
    elseif isa(expr, Expr) 
        if expr.head == :call && expr.args[1] != :|
            # compounds term goes to structure
            functor_name = string(expr.args[begin])
            args = [macro_parse_term(e) for e in expr.args[2:end]]
            s = Structure(c_functor(functor_name, length(args)), args)
            return :($s)
        elseif expr.head == :call && expr.args[1] == :|
            # turns into a LPair
            head = macro_parse_term(expr.args[2])
            tail = macro_parse_term(expr.args[3])
            p = LPair(head, tail)
            return :($p)
        elseif expr.head == :vect
            # turn into list
            elems = [macro_parse_term(e) for e in expr.args]
            l = List(elems)
            return :($l)
        end
    end
end

function macro_parse_body(expr::Union{Symbol,Expr})
    if expr.args[begin] == :&
        # parse a conjunction
        left = macro_parse_body(expr.args[2])
        right = macro_parse_top(expr.args[3])
        push!(left, right)
        return :($left)
    else
        # parse single literal
        container = Vector{Union{Literal, Negation, Proposition}}()
        push!(container, macro_parse_top(expr))
        return container
    end
end

function macro_parse_top(expr::Union{Symbol,Expr})
    if isa(expr, Symbol)
        # a symbol on a top level turns into a propositions
        prop = c_prop(string(expr))
        return :($prop)
    elseif expr.head == :vect
        # list of clauses, turn into a Program
        clauses = [macro_parse_top(e) for e in expr.args]
        prog = Program(clauses)
        return :($prog)
    elseif expr.head == :call
        if expr.args[begin] == :<=
            #parse clause 
            head = macro_parse_top(expr.args[2])
            body = macro_parse_body(expr.args[3])
            cl = Clause(head, Conj(body))
            return :($cl)
        elseif expr.args[begin] == :! && length(expr.args) == 2
            # parse negation
            lit = macro_parse_top(expr.args[2])
            neg = Negation(lit)
            return :($neg)
        else
            # parse literal 
            pred_name = string(expr.args[begin])
            args = [macro_parse_term(e) for e in expr.args[2:end]]
            lit = Literal(c_pred(pred_name, length(args)), args)
            return :($lit)
        end
    end
end

macro prolog(expr)
    return macro_parse_top(expr)
end


function parse_disjunction(expr)
    if expr.head == :(::)
        #parse single literal
        container = Vector{ProbabilisticLiteral}()
        push!(container, macro_probabilistic_parse_top(expr))
        return container
    else
        #parse disjunction 
        left = parse_disjunction(expr.args[2])
        right = macro_probabilistic_parse_top(expr.args[3])
        push!(left, right)
        return :($left)
    end
end


function isdisjunction(expr)
    if expr.args[begin] == :|
        true
    else
        false
    end
end


function macro_probabilistic_parse_top(expr::Union{Expr,Symbol})
    if expr.head == :(::)
        #parse probabilistic literal
        prob = expr.args[begin]
        literal = macro_parse_top(expr.args[2])
        plit = ProbabilisticLiteral(prob,literal)
        return :($plit)
    elseif expr.head == :call 
        if isdisjunction(expr)
            heads = parse_disjunction(expr)
            ad = AnnotatedDisjunction(heads, true)
            return :($ad)
        elseif expr.args[begin] == :<= && isdisjunction(expr.args[2])
            heads = parse_disjunction(expr.args[2])

            if isa(expr.args[3], Union{Expr, Symbol})
                # if body is a conjunction
                body = macro_parse_top(expr.args[3])
                ad = AnnotatedDisjunction(heads, body)
                return :($ad)
            else
                # if body is true
                ad = AnnotatedDisjunction(heads, expr.args[3])
                return :($ad)
            end
        else
            #otherwise proceeds as normal
            return macro_parse_top(expr)
        end
    else 
        # parse as normal logic program
        return macro_parse_top(expr)
    end
end

macro problog(expr)
    macro_probabilistic_parse_top(expr)
end


expr_to_prolog(ex) = macro_parse_top(ex)

expr_to_problog(ex) = macro_probabilistic_parse_top(ex)


