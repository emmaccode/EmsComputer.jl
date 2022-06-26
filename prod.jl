using Pkg; Pkg.activate(".")
Pkg.update()
using Toolips
using EmsComputer
IP = "127.0.0.1"
PORT = 8000
extensions = [Logger(), Files("public")]
EmsServer = EmsComputer.start(IP, PORT, EmsComputer.make_routes(),
        extensions = extensions)
