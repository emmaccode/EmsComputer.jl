function build_blog_bar()
    blog_lg = img(src = "images/animated-dark.gif", width = 40px, style = "padding:.5%;cursor:pointer;user-select:none;", 
        onclick = "'window.location.href = \"/\";'")
    blog_shower = a(text = "em's journals")
    style!(blog_shower, "font-size" => 20pt, "font-weight" => "bold", "color" => "#5b33b0", 
        "padding" => .5percent, "margin-left" => 2percent, "user-select" => "none")
    menu_latest = a("latestmen", text = "latest", class = "blogmenubutton", style = "margin-left:30px;")
    container = div("bar", children = [blog_lg, blog_shower, menu_latest])
    style!(container, "background-color" => "#0f0f0f", "width" => 99percent, 
        "position" => "sticky", "top" => 0percent, "padding" => .5percent, "display" => "inline-block", 
        "border-bottom-left-radius" => 4pt, "border-bottom-right-radius" => 4pt)
    
    container::Component{:div}
end

blog_menubutton_class = style("a.blogmenubutton", "border-left" => "4px solid #8833b0", "border-top-right-radius" => 6pt,
    "cursor" => "pointer", "padding" => .5percent, "color" => "#d4cfb0", "font-size" => 20pt, "padding-left" => 1.5percent, "padding-right" => 1.5percent, 
    "transition" => 400ms)
blog_menubutton_class:"hover":["background-color" => "#0a0a0a", "color" => "#854a96", "border-bottom" => "4px solid #854a96", "font-weight" => "bold"]

blog_route = route("/blog") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar()], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

push!(EmsComputer.ROUTES, blog_route)