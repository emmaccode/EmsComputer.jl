using Pkg; Pkg.activate(".")
Pkg.update()

using Toolips

IP = "127.0.0.1"
PORT = 8000
extensions = Dict(:logger => Logger(), :public => Files("public"))

include("src/EmsComputer.jl")
