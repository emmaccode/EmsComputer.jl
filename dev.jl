using Pkg

Pkg.activate(".")

using Toolips
using ToolipsSession
using Revise

using EmsComputer

IP = "127.0.0.1"
PORT = 8000
extensions = [Logger(), Files("public"), Session()]
EmsServer = EmsComputer.start(IP, PORT, EmsComputer.make_routes(),
        extensions = extensions)

function update_routes(w::WebServer)
        route!(w, "/", EmsComputer.home)
end
