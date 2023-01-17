# Origin

[![Build Status](https://travis-ci.com/okamumu/Origin.jl.svg?branch=master)](https://travis-ci.com/okamumu/Origin.jl)
[![Codecov](https://codecov.io/gh/okamumu/Origin.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/okamumu/Origin.jl)
[![Coveralls](https://coveralls.io/repos/github/okamumu/Origin.jl/badge.svg?branch=master)](https://coveralls.io/github/okamumu/Origin.jl?branch=master)

Origin.jl provides a simple way to zero-origin vector and matrix with a Julia macro.

## Installation

This is not in the official package of Julia yet. Please run the following command to install it.
```
using Pkg; Pkg.add(PackageSpec(url="https://github.com/JuliaReliab/Origin.jl.git"))
```

## Load module

The module is loaded:
```
using Orign
```

## How to use

The package provides a macro `@origin` only. The arguments of `@origin` macro are 
```julia
@macro {Tuple of :(=>)} {expr}
```
The tuple lists variables whose indexes are changed. The origin of index is indicated by an argument of `:(=>)`. For example, `x => 0` means the origin of vector or matrix `x` is 0. The macro changes the indexes of listed variables in the tuple in the given block as the second argument.

## Example

The following example uses two vector `x` and `y` whose origins are changed.

```julia
@origin (x=>0, y=>2) begin
    x = [0 for v = 1:3]
    y = [0 for v = 1:3]
    x[0] = 0
    x[1] = 1
    x[2] = 2
#    x[3] = 3 # error!
#    y[1] = 1 # error!
    y[2] = 2
    y[3] = 3
    y[4] = 4
    println(x) ### [0, 1, 2]
    println(y) ### [2, 3, 4]
end
```

## Notice

This package is just to change the number which are bracket by `[]` so that it is adjust to the given origin.
Therefore the package is not applied to `eachindex` yet. The **error** occurs in the following example:

```julia
@origin (x=>0) begin
    x = [0 for v = 1:3]
    for i = eachindex(x)
        x[i] = i
    end
    println(x)
end
```
