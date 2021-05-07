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