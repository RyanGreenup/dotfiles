# FezzikAutoGenStart
# to remove remove entire block
try
    using Fezzik
    try
        Fezzik.trace()
    catch err
        @info "Something went wrong" err
    end
catch e
    try
        using Pkg
        Pkg.add("Fezzik")
        import Fezzik
        try
            Fezzik.trace()
        catch err
            @info "Something went wrong" err
        end
    catch err
        @info "Something went wrong" err
    end
end

# FezzikAutoGenEnd



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



