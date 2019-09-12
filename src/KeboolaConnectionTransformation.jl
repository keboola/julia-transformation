module KeboolaConnectionTransformation
using Pkg
using KeboolaConnectionComponent

function run()::Integer
    config = KeboolaConnectionComponent.config()
    datadir = KeboolaConnectionComponent.datadir()
    parameters = config.parameters

    # prepare the script file
    script = join(get(parameters, "script", []), "\n")
    scriptPath = joinpath(datadir, "script.jl")
    open(scriptPath, "w") do file
        write(file, script)
    end
    print("Script file: " * scriptPath)

    # install packages
    packages = get(parameters, "packages", [])
    for package in Iterators.Stateful(packages)
        try
            Pkg.add(package)
        catch e
            throw(ArgumentError("Failed to install package '" * package * "' error: " * e.msg))
        end
    end
    if length(packages) > 0
        Pkg.resolve()
    end

    # Change current working directory so that relative paths work
    cd(datadir)

    try
        include(scriptPath)
    catch e
        throw(ArgumentError("The transformation script failed: " * sprint(showerror, e)))
    end
    println("Script finished")
    return 0
end

end # module
