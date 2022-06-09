using Toolips
IP = "ems.computer"
PORT = 8000
extensions = Dict(:logger => Logger(), :public => Files("public"))
include("src/EmsComputer.jl")
