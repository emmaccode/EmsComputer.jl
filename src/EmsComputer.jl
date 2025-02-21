module EmsComputer
using Toolips
import Toolips: on_start
import Base: getindex
using Toolips.Components
using ToolipsSession
using JSON
using TOML
include("Pages.jl")
include("Styles.jl")
SESSION = Session(["/"])
include("desktop.jl")
include("posts.jl")


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

clients = Toolips.QuickExtension{:clients}()

files = mount("/" => "public")
export computer_main, fourofour, SESSION, files, clients
end # - module
