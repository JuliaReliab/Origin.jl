# Origin.jl

[![Build Status](https://travis-ci.com/okamumu/Origin.jl.svg?branch=master)](https://travis-ci.com/okamumu/Origin.jl)
[![Codecov](https://codecov.io/gh/okamumu/Origin.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/okamumu/Origin.jl)
[![Coveralls](https://coveralls.io/repos/github/okamumu/Origin.jl/badge.svg?branch=master)](https://coveralls.io/github/okamumu/Origin.jl?branch=master)

`Origin.jl` provides a simple macro to use **non-1-based indexing (e.g., 0-origin or 2-origin)** for vectors and matrices inside a limited code block.

It statically rewrites index expressions such as `a[i]`, `a[m:n]`, and `a[m:s:n]` within a macro block, so you can access elements using the desired origin while keeping the actual underlying arrays 1-based.

---

## Installation

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/JuliaReliab/Origin.jl.git"))
```

---

## Load module

```julia
using Origin
```

---

## Basic usage

The `@origin` macro changes index origins **only within the given block**:

```julia
@origin (x => 0, y => 2) begin
    x = [10, 11, 12]
    y = [20, 21, 22, 23]
    println(x[0])  # 10
    println(x[2])  # 12
    println(y[2])  # 20
    println(y[5])  # 23
end
```

The macro expands every array reference `x[...]` or `y[...]` by adding or subtracting offsets corresponding to the specified origins.

---

## Supported syntax

| Feature         | Example                                    | Notes                                 |
| --------------- | ------------------------------------------ | ------------------------------------- |
| Simple indexing | `x[0]`, `y[2]`                             | shifted by origin                     |
| Colon range     | `x[0:3]`, `y[2:6]`                         | left/right bounds adjusted            |
| Range with step | `x[0:2:10]`                                | step unchanged                        |
| `end` keyword   | `x[2:end]`                                 | left bound shifted; `end` kept intact |
| Nested macro    | allowed (inner definition overrides outer) |                                       |

Example with `end`:

```julia
@origin (a=>0, b=>2) begin
    a = collect(0:10)
    b = collect(1:5)
    @test a[0:end] == collect(0:10)
    @test b[2:end] == [1, 2, 3, 4, 5]
end
```

---

## Handling of `eachindex`

From version ≥ 0.3, `@origin` safely expands `eachindex` into **logical index ranges** consistent with the declared origins.

| Pattern          | Transformed internally                                                    |
| ---------------- | ------------------------------------------------------------------------- |
| `eachindex(a)`   | `origin(a) : origin(a) + length(a) - 1`                                   |
| `eachindex(a,b)` | common range of both logical axes (`max(lo_a, lo_b)` : `min(hi_a, hi_b)`) |

Example:

```julia
@origin (a=>0, b=>2) begin
    a = [0, 0, 0, 0]
    b = [0, 0, 0, 0, 0]
    for i in eachindex(a, b)
        a[i] = i
        b[i] = 10i
    end
    println(a)  # [0,1,2,3]
    println(b)  # [20,30,40,50,60]
end
```

If `eachindex` is applied to arrays not listed in the macro argument, it is left unchanged and a warning is printed.

---

## Notes and limitations

* The macro rewrites only **literal index expressions** inside the block.
  Dynamic indices computed in other functions are unaffected.
* `end-1` or other arithmetic with `end` is not yet supported.
* **⚠️ Multi-dimensional arrays**: When applied to matrices or higher-dimensional arrays, **all dimensions share the same origin**.
  For example, `x=>0` gives `x[0,0]` as the logical top-left element (mapped to physical `x[1,1]`).
  If you need different origins per dimension, use separate 1-D slices or consider [`OffsetArrays.jl`](https://github.com/JuliaArrays/OffsetArrays.jl).
* Nested `@origin` blocks override outer definitions unless the same origins are re-declared explicitly.
* The macro does **not** modify array axes; underlying arrays remain 1-based.

If full offset indexing (including `axes`, `eachindex`, etc.) is desired across all code, consider using [`OffsetArrays.jl`](https://github.com/JuliaArrays/OffsetArrays.jl), which provides native support for non-1-based axes with almost no performance penalty.
You can also combine both approaches: use `@origin` for local index shifts and `OffsetArrays` for global offset semantics.

---

## Example test set

```julia
using Test, Origin

@testset "Test for colon and end" begin
@origin (a=>0, b=>2) begin
    a = collect(0:10)
    b = collect(1:5)

    @test a[0:5] == [0,1,2,3,4,5]
    @test b[2:6] == [1,2,3,4,5]
    @test a[0:2:end] == [0,2,4,6,8,10]
    @test a[5:end] == collect(5:10)
    @test b[4:end] == [3,4,5]
end
end
```

---

## License

MIT License © 2025 Hiroyuki Okamura / Hiroshima University Dependable Systems Lab

