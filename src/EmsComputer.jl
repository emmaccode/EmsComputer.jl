module EmsComputer
using Toolips

include("Styles.jl")
include("Pages.jl")
"""
### start(ip::String, port::Integer, routes::Vector{Route};
    extensions::Dict = Dict(:logger => Logger(),
    :public => Files("public")))) -> ::Toolips.WebServer
-------------------------------------
Creates Toolips WebServer from provided routes and starts on provided IP/Port.
#### example
```
using EmsComputer
ip = "127.0.0.1"
port = 8000
r = route("/") do c::Connection
    write!(c, h("", 1, text = "Hello World!"))
end

server = EmsComputer.start(ip, port, [r])
```
"""
function start(IP::String, PORT::Integer, routes::Vector{Route};
    extensions::Dict = Dict(:logger => Logger(), :public => Files("public")))
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end

function make_routes()
    fourofour = route("404") do c
        header = make_header()
        write!(c, heading1_style)
        write!(c, heading2_style)
        write!(c, header)
        errormessage = h("4041", 1, text = "404")
        second = h("4042", 2, text = "It looks like something went wrong.")
        style!(errormessage, heading1_style)
        style!(second, heading2_style)
        write!(c, errormessage)
        write!(c, second)
    end
    homepage = route("/", home)
    routes(homepage, fourofour)
end

end # - module
