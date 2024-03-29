module EmsComputer
using Toolips
using ToolipsSession
using ToolipsDefaults
using JSON
using TOML
include("Pages.jl")

mutable struct Post <: Servable
    ID::String
    readcount::Int64
    stars::Int64
    title::String
    sub::String
    img::String
    tags::Vector{String}
    uri::String
    function Post(uri::String)
        p = read(uri, String)
        metas = findfirst("```meta", p)
        imgs = findfirst("```img", p)
        metar = maximum(metas) + 1:findnext("```", p, metas[2])[1] - 1
        imgr = maximum(imgs) + 1:findnext("```", p, imgs[2])[1] - 1
        imgdata = p[imgr]
        metainfo = TOML.parse(p[metar])
        ID = ToolipsSession.gen_ref(16)
        new(ID, metainfo["readcount"], metainfo["stars"], metainfo["title"],
        metainfo["sub"], imgdata, Vector{String}(split(metainfo["tags"], ",")), uri)
    end
end

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
function start(IP::String, PORT::Integer, routes;
    extensions)
    server = ServerTemplate(IP, PORT, routes = routes, extensions = extensions)
    server.start()
end

function make_routes()
    fourofour = route("404") do c
        header = make_header("/images/animated.gif")
        write!(c, text_styles())
        write!(c, header)
        errormessage = h("4041", 1, text = "404")
        second = h("4042", 2, text = "It looks like something went wrong.")
        style!(errormessage, text_styles()[1])
        style!(second, text_styles()[2])
        write!(c, components(errormessage, second))
    end
    homepage = route("/", home)
    routes(homepage, fourofour)
end

end # - module
