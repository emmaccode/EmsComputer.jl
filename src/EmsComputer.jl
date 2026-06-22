module EmsComputer
using Toolips
import Toolips: on_start
import Base: getindex
using Toolips.Components
using ToolipsSession
using JSON
using TOML

function text_styles()
    heading1_style = Style("h1")
    heading1_style["color"] = "white"
    heading2_style = Style("h2")
    heading2_style["color"] = "gray"
    graytxt = Style("p")
    graytxt[:color] = "gray"
    [heading1_style, heading2_style, graytxt]
end

function anim_logoin()
    lfade = keyframes("lfadein")
    keyframes!(lfade, :from, "opacity" => 0percent, "transform" => translateX(100percent))
    keyframes!(lfade, :to, "opacity" => 100percent, "transform" => translateX(0percent))
    lfade
end

function move_mainup()
    animat = keyframes("maingoup")
    keyframes!(animat, :from, "transform" => translatyY(0percent))
    keyframes!(animat, :to, "transform" => translateY(-120percent))
    animat
end



function anim_logoout()
    lfade = keyframes("lfadeout")
    keyframes!(lfade, :from, "opacity" => 100percent, "transform" => translateX(0percent))
    keyframes!(lfade, :to, "opacity" => 0percent, "transform" => translateX(-100percent))
    lfade
end

function logo_sty()
    logo_style = Style("img.logo")
    logo_style[:width] = "250"
    style!(logo_style, "animation-name" => "lfadein", "animation-duration" => 800ms)
    logo_style
end

function button_style()
    style = Style("button", padding = "20px")
    style["background-color"] = "pink"
    style["font-size"] = "15pt"
    style["color"] = "white"
    style
end

function stylesheet()
    vcat([logo_sty(), button_style(), anim_logoin(), anim_logoout(),
    move_mainup()],
    text_styles())
end


function create_styles()
    stylsheet::Component{:sheet} = Component{:sheet}("emsstyles")
    button_style = style("button", "padding" => 10px, "font-weight" => "bold", "font-size" => 11pt, 
    "color" => "white", "background-color" => "#481d4a", "border-radius" => 3px, 
    "border" => "1px solid #1e1e1e", "cursor" => "pointer")
    h1_sty = style("h1", "color" => "#32a852", "font-size" => 30pt)
    h2_sty = style("h2", "color" => "white", "font-size" => 25pt)
    h3_sty = style("h3", "color" => "#ccccff", "font-size" => 20pt)
    h4_sty = style("h4", "color" => "white", "font-size" => 20pt)
    p_sty = style("p", "color" => "white", "font-size" => 14pt)
    post_body = style("section.postbody", "background-color" => "#292929", "border" => "1px solid black",
    "border-radius" => 4px, "padding" => 10px, "margin" => .5percent, "cursor" => "pointer")
    post_body:"hover":["transform" => scale(1.05)]
    push!(stylsheet, button_style, h1_sty, h2_sty, h3_sty, h4_sty, p_sty, post_body)
    stylsheet::Component{:sheet}
end

SESSION = Session(["/"])
include("desktop.jl")
include("pages/posts.jl")
include("pages/models.jl")
include("pages/packages.jl")
include("pages/games.jl")
include("pages/software.jl")

fourofour = route("404") do c
    header = build_logo_header()
    set_style!(header, "padding" => 10percent)
    write!(c, text_styles())
    write!(c, header)
    errormessage = h1("4041", text = "404")
    second = h2("4042", text = "Error 404, page not found")
    style!(errormessage, "padding" => 50px, "color" => "#2f2c3d")
    style!(second, "color" => "#56516e", "padding" => 50px)
    back_button = button("back", text = "back to em's computer", align = "center")
    style!(back_button, "padding" => 1percent, "background-color" => "#5445a1", "cursor" => "pointer")
    on(cl -> redirect!(cl, "/"), back_button, "click")
    write!(c, errormessage, second, back_button)
end

clients = Toolips.QuickExtension{:clients}()

files = mount("/" => "public")

model_viewer_files = mount("/modelview" => "glbviewer")

export computer_main, fourofour, SESSION, files, clients, model_viewer_files
end # - module
