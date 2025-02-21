module EmsComputer
using Toolips
using Toolips.Components
using ToolipsSession
using JSON
using TOML
include("Pages.jl")
include("Styles.jl")
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


fourofour = route("404") do c
    header = make_header(c, "/images/animated.gif")
    write!(c, text_styles())
    write!(c, header)
    errormessage = h1("4041", text = "404")
    second = h2("4042", text = "It looks like something went wrong.")
    style!(errormessage, text_styles()[1])
    style!(second, text_styles()[2])
    write!(c, errormessage, second)
end

homepage = route(home_splash, "/")

SESSION = Session(["/"])
files = mount("/" => "public")
export homepage, fourofour, SESSION, files
end # - module
