using Test
using KeboolaConnectionTransformation
using JSON
import KeboolaConnectionComponent

function createconfig(data)
    path = mktempdir();
    ENV["KBC_DATADIR"] = path
    open(path * "/config.json", "w") do file
        JSON.print(file, data, 4)
    end
    path
end

function getconfigdata()
    Dict(
        "storage" => Dict(
            "input" => Dict(
                "tables" => [
                    Dict(
                        "source" => "in.c-main.data",
                        "destination" => "sample.csv"
                    )
                ]
            ),
            "output" => Dict(
                "tables" => [
                    Dict(
                        "source" => "sample.csv",
                        "destination" => "out.c-main.data"
                    )
                ]
            )
        ),
        "parameters" => Dict(
        )
    )
end

@testset "basic run" begin
    data = getconfigdata()
    data["parameters"] = Dict(
        "packages" => ["CSV", "LightXML"],
        "script" => ["println(\"Hello\")", "println(\"World\")\nusing LightXML"]
    )
    path = createconfig(data)
    ENV["KBC_DATADIR"] = path
    @test KeboolaConnectionTransformation.run() == 0

    open(joinpath(path, "script.jl"), "r") do file
        script = read(file, String)
        @test script == "println(\"Hello\")\nprintln(\"World\")\nusing LightXML"
    end
    @test pwd() == path

    delete!(ENV, "KBC_DATADIR")
end

@testset "no packages" begin
    data = getconfigdata()
    data["parameters"] = Dict(
        "packages" => [],
        "script" => ["println(\"Hello\")\nprintln(\"World\")"]
    )
    path = createconfig(data)
    ENV["KBC_DATADIR"] = path
    @test KeboolaConnectionTransformation.run() == 0

    open(joinpath(path, "script.jl"), "r") do file
        script = read(file, String)
        @test script == "println(\"Hello\")\nprintln(\"World\")"
    end
    @test pwd() == path

    delete!(ENV, "KBC_DATADIR")
end

@testset "invalid package" begin
    data = getconfigdata()
    data["parameters"] = Dict(
        "packages" => ["CSV", "non existent package"],
        "script" => ["println(\"Hello\")", "println(\"World\")\nusing LightXML"]
    )
    path = createconfig(data)
    ENV["KBC_DATADIR"] = path
    try
        KeboolaConnectionTransformation.run()
    catch e
        @test e isa ArgumentError
        @test e.msg == "Failed to install package 'non existent package' error: `non existent package` is not a valid package name"
    end
    delete!(ENV, "KBC_DATADIR")
end

@testset "invalid script" begin
    data = getconfigdata()
    data["parameters"] = Dict(
        "packages" => [],
        "script" => ["println(\"Hello\")", "this is not a valid code"]
    )
    path = createconfig(data)
    ENV["KBC_DATADIR"] = path
    try
        KeboolaConnectionTransformation.run()
    catch e
        @test e isa ArgumentError
        @test occursin("The transformation script failed: LoadError: syntax: extra token \"is\" after end of expression\nin expression starting at", e.msg)
        @test occursin("script.jl:2", e.msg)
    end
    delete!(ENV, "KBC_DATADIR")
end
