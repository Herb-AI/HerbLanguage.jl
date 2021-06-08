@testset "Language" begin
    a = c_const("a")
    b = c_const("b")

    @test isa(a, Constant)
    @test isa(b, Constant)

    f = c_functor("f", 1)
    p = c_pred("p", 2)

    @test isa(f, Functor)
    @test isa(p, Predicate)

    s = f(a)
    @test isa(s, Structure)

    lit = p(a,b)
    @test isa(lit, Literal)

    vX = c_var("X")
    vY = c_var("Y")

    q = c_pred("q", 2)

    h = q(vX, vY)
    @test isa(h, Literal)

    clause = p(vX) <= q(vX, vY)
    @test isa(clause, Clause)

    clause2 = p(vX) <= q(vX, vY) & p(vY)
    @test isa(clause2, Clause)

    n = c_pred("n", 1)
    lit_n1 = n(1)
    @test isa(lit_n1, Literal)
end