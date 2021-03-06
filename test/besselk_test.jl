# general array for testing input to SpecialFunctions.jl
x = 1e-5:0.01:50.0

### Tests for besselk0
k0_SpecialFunctions = SpecialFunctions.besselk.(0, x) 

k0_64 = besselk0.(Float64.(x))
k0_32 = besselk0.(Float32.(x))

# make sure output types match input types
@test k0_64[1] isa Float64
@test k0_32[1] isa Float32

# test against SpecialFunctions.jl
@test k0_64 ≈ k0_SpecialFunctions
@test k0_32 ≈ k0_SpecialFunctions

### Tests for besselk0x
k0x_SpecialFunctions = SpecialFunctions.besselkx.(0, x) 

k0x_64 = besselk0x.(Float64.(x))
k0x_32 = besselk0x.(Float32.(x))

# make sure output types match input types
@test k0x_64[1] isa Float64
@test k0x_32[1] isa Float32

# test against SpecialFunctions.jl
@test k0x_64 ≈ k0x_SpecialFunctions
@test k0x_32 ≈ k0x_SpecialFunctions

### Tests for besselk1
k1_SpecialFunctions = SpecialFunctions.besselk.(1, x) 

k1_64 = besselk1.(Float64.(x))
k1_32 = besselk1.(Float32.(x))

# make sure output types match input types
@test k1_64[1] isa Float64
@test k1_32[1] isa Float32

# test against SpecialFunctions.jl
@test k1_64 ≈ k1_SpecialFunctions
@test k1_32 ≈ k1_SpecialFunctions

### Tests for besselk1x
k1x_SpecialFunctions = SpecialFunctions.besselkx.(1, x) 

k1x_64 = besselk1x.(Float64.(x))
k1x_32 = besselk1x.(Float32.(x))

# make sure output types match input types
@test k1x_64[1] isa Float64
@test k1x_32[1] isa Float32

# test against SpecialFunctions.jl
@test k1x_64 ≈ k1x_SpecialFunctions
@test k1x_32 ≈ k1x_SpecialFunctions

### Tests for besselk
@test besselk(0, 2.0) == besselk0(2.0)
@test besselk(1, 2.0) == besselk1(2.0)

@test besselk(5, 8.0) ≈ SpecialFunctions.besselk(5, 8.0)
@test besselk(5, 88.0) ≈ SpecialFunctions.besselk(5, 88.0)

@test besselk(100, 3.9) ≈ SpecialFunctions.besselk(100, 3.9)
@test besselk(100, 234.0) ≈ SpecialFunctions.besselk(100, 234.0)

# test small arguments and order
m = 0:40; x = [1e-6; 1e-4; 1e-3; 1e-2; 0.1; 1.0:2.0:700.0]
@test [besselk(m, x) for m in m, x in x] ≈ [SpecialFunctions.besselk(m, x) for m in m, x in x]

# test medium arguments and order
m = 30:200; x = 5.0:5.0:100.0
t = Float64.([besselk(m, x) for m in m, x in x])
@test t ≈ [SpecialFunctions.besselk(m, x) for m in m, x in x]

# test large orders
m = 200:5:1000; x = 400.0:10.0:1200.0
t = Float64.([besselk(m, x) for m in m, x in x])
@test t ≈ [SpecialFunctions.besselk(m, x) for m in m, x in x]

# Float 32 tests for aysmptotic expansion
m = 20:5:200; x = 5.0f0:2.0f0:400.0f0
t = [besselk(m, x) for m in m, x in x]
@test t[10] isa Float32
@test t ≈ Float32.([SpecialFunctions.besselk(m, x) for m in m, x in x])

# test for low values and medium orders
m = 20:5:50; x = [1f-3, 1f-2, 1f-1, 1f0, 1.5f0, 2.0f0, 4.0f0]
t = [besselk(m, x) for m in m, x in x]
@test t[5] isa Float32
@test t ≈ Float32.([SpecialFunctions.besselk(m, x) for m in m, x in x])

@test iszero(besselk(20, 1000.0))
#@test isinf(besselk(250, 5.0))

### Tests for besselkx
@test besselkx(0, 12.0) == besselk0x(12.0)
@test besselkx(1, 89.0) == besselk1x(89.0)

@test besselkx(15, 82.123) ≈ SpecialFunctions.besselk(15, 82.123)*exp(82.123)
@test besselkx(105, 182.123) ≈ SpecialFunctions.besselk(105, 182.123)*exp(182.123)
