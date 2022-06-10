using Pkg

Pkg.activate(".")

using Toolips
IP = "127.0.0.1"
PORT = 8000
extensions = Dict(:logger => Logger(), :public => Files("public"))
using Revise

using EmsComputer

EmsServer = EmsComputer.start(IP, PORT, EmsComputer.make_routes(),
        extensions = extensions)

function update_routes(w::WebServer)
        route!(w, "/", EmsComputer.home)
end
