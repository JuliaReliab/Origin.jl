#
# This is a package to convert to use zero origin array in a function.
# Usage:
#  @zeroorigin [single symbol or list/tuple for variables with zeroorigin] [definition of function]
#
# When we definie a function, the code `@zeroorigin (x,y)` is added to the head of definition.
# Then in the function, the ref of x and y, i.e., x[i] and y[i] will be changed to x[i+1] and y[i+1].
#
# Example:
#
# using Origin
# using Test
#
# @testset "Origin.jl" begin
#     @origin (a=>0, b=>2) function test()
#         a = collect(0:10)
#         b = collect(1:5)
#         @test a[0] == 0
#         @test a[10] == 10
#         @test b[2] == 1
#         @test b[4] == 3
#         @test b[end] == 5
#         @test b[2:end] == [1, 2, 3, 4, 5]
#         @test b[a[5]] == 4
#     end

#     test()
# end

export @origin

function peek(stack)
    return stack[end]
end

function _changeindex(expr, u)
    if Meta.isexpr(expr, :call) && expr.args[1] == :(:)
        if length(expr.args) == 3
            Expr(:call, :(:), Expr(:call, :+, expr.args[2], u), Expr(:call, :+, expr.args[3], u))
        elseif length(expr.args) == 4
            Expr(:call, :(:), Expr(:call, :+, expr.args[2], u), expr.args[3], Expr(:call, :+, expr.args[4], u))
        else
            error("The inner of index should be a simple expr or call :(:)")
        end
    else
        Expr(:call, :+, expr, u)
    end
end

function _replace(expr::Expr, symlist, stack)
    if Meta.isexpr(expr, :ref)
        push!(stack, expr.args[1])
        args = Any[_replace(x, symlist, stack) for x = expr.args]
        if haskey(symlist, peek(stack))
            m = symlist[peek(stack)]
            u = Expr(:call, :-, 1, m)
            for i = 2:length(args)
                args[i] = _changeindex(args[i], u)
            end
        end
        pop!(stack)
        Expr(expr.head, args...)
    elseif Meta.isexpr(expr, :macrocall) && expr.args[1] == Symbol("@origin")
        macroexpand(Origin, expr, recursive=false)
    else
        if Meta.isexpr(expr, :call) && expr.args[1] == :eachindex
            if _hassym(expr.args[2], symlist)
                println("Warning: This macro has not been applied to the block including 'eachindex' yet.")
            end
        end
        args = Any[_replace(x, symlist, stack) for x = expr.args]
        Expr(expr.head, args...)
    end
end

function _replace(expr::Symbol, symlist, stack)
    if expr == :end && haskey(symlist, peek(stack))
        m = symlist[peek(stack)]
        Expr(:call, :-, :end, Expr(:call, :-, 1, m))
    else
        expr
    end
end

function _replace(expr::Any, symlist, stack)
    expr
end

function _hassym(expr::Expr, symlist)
    any(Bool[_hassym(x, symlist) for x = expr.args])
end

function _hassym(expr::Symbol, symlist)
    haskey(symlist, expr)
end

function _add!(symlist, x)
    if typeof(x) <: Expr && x.head == :call && x.args[1] == :(=>)
        symlist[x.args[2]] = x.args[3]
    end
end

macro origin(vars, expr)
    symlist = Dict{Symbol,Any}()
    stack = []
    if typeof(vars) <: Expr && (vars.head == :vect || vars.head == :tuple)
        for x = vars.args
            _add!(symlist, x)
        end
    else
        _add!(symlist, vars)
    end
    ex = _replace(expr, symlist, stack)
    esc(ex)
end

