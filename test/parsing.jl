@testset "Parsing" begin
 
    @test isa(from_string("a", base=false), Constant)
    @test isa(from_string("X"), Variable)
    @test from_string("a").name == "a"
    @test isa(from_string("_"), Variable)
    @test isa(from_string("'UppercaseConstant'", base=false), Constant)

    s = from_string("t(a,b,c)", base=false)
    @test isa(s, Structure)
    @test s.functor.arity == 3
    @test all(isa(a, Constant) for a in s.arguments)

    l = from_string("pred(a,X)")
    @test isa(l, Literal)
    @test l.predicate.arity == 2
    @test isa(l.arguments[begin], Constant)
    @test isa(l.arguments[2], Variable)

    l2 = from_string("[1,2,3,4,5]")
    @test isa(l2, List)
    @test all([isa(a, Integer) for a in l2.elements])

    l3 = from_string("[H|T]")
    @test isa(l3, LPair)

    l4 = from_string("p([a,b,c], s(1,2))")
    @test isa(l4, Literal)
    @test isa(l4.arguments[begin], List)
    @test isa(l4.arguments[2], Structure)

    cl = from_string("h(X,Y) :- p(X,Z), q(Z,Y), r(Z)")
    @test isa(cl, Clause)

end

@testset "macro parsing" begin
    program = @prolog [
        a,
        p(a, b),
        p(X),
        q(X,Y),
        p(1),
        r(a, s(b,c)),
        r(c, s(c,X)),
        p(X) <= q(X,Y) & z(Y),
        p2(X) <= p(X) & !z(X),
        p3(X|Y, Z) <= r(X,Z) & z(Y)
    ]

    clauses = program.clauses

    @test isa(clauses[begin], Proposition)
    @test isa(clauses[2], Literal)
    @test is_ground(clauses[2])
    @test isa(clauses[3], Literal)
    @test isa(clauses[4], Literal)
    @test isa(clauses[5], Literal)
    @test isa(clauses[6], Literal)
    @test isa(clauses[7], Literal)
    @test isa(clauses[8], Clause)
    @test isa(clauses[9], Clause)
    @test isa(clauses[10], Clause)

end


@testset "problog macro parsing" begin
    @test isa((@problog 0.5::p | 0.5::q), AnnotatedDisjunction)
    @test isa((@problog 0.5::p(X) | 0.5::q(X)), AnnotatedDisjunction)
    @test isa((@problog 0.3::p(X,a) | 0.3::p(X,b) | 0.3::p(X,c)), AnnotatedDisjunction)
end