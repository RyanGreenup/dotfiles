# print("Current Working directory is:", pwd())
#=
This conflicts with Iron
atreplinit() do repl
    try
        @eval using OhMyREPL
    catch e
        @warn "error while importing OhMyREPL" e
    end
end
=#
