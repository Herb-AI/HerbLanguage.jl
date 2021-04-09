@testset "Parsing" begin
 
    @test isa(parse_prolog("a"), Constant)
    @test isa(parse_prolog("X"), Variable)
    @test parse_prolog("a").name == "a"
    @test isa(parse_prolog("_"), Variable)
    @test isa(parse_prolog("'UppercaseConstant'"), Constant)

end