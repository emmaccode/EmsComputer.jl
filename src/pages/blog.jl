function build_blog_bar(men_selected::String = "")
    blog_lg = img(src = "/images/animated-dark.gif", width = 40px, style = "padding:.5%;cursor:pointer;user-select:none;", 
        onclick = "'window.location.href = \"/\";'")
    blog_shower = a(text = "em's journals")
    style!(blog_shower, "font-size" => 20pt, "font-weight" => "bold", "color" => "#5b33b0", 
        "padding" => .5percent, "margin-left" => 2percent, "user-select" => "none")
    menu_home = a("homemen", text = "home", class = "blogmenubutton", style = "margin-left:10px;", 
        onclick = "'window.location.href = \"/blog\";'")
    menu_latest = a("latestmen", text = "latest", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/latest\";'")
    menu_cats = a("catmen", text = "categories", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/categories\";'")
    menu_series = a("sermen", text = "series", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/series\";'")
    searchbar = a("searchtxt", contenteditable = "true")
    common = ("padding" => .5percent, "background-color" => "#242424", "border-radius" => 2pt, 
        "font-size" => 15pt, "float" => "right")
    style!(searchbar, "background-color" => "#242424", "width" => 23percent, "overflow" => "visible",
        "white-space" => "nowrap", "border" => "2px solid #854a96", "border-right" => 0px, common ...)
    iconbutton = a("srch", text = "search")
    style!(iconbutton, "border" => "2px solid #854a96", "border-left" => 0px, common ...)
    container = div("bar", children = [blog_lg, blog_shower, menu_home, menu_latest, menu_cats, menu_series, 
        searchbar, iconbutton])
    if ~(men_selected == "")
        sel_menu = container[:children][men_selected]
        sel_menu[:onclick] = ""
    end
    style!(sel_menu, "background-color" => "#5b33b0")
    style!(container, "background-color" => "#0f0f0f", "width" => 99percent, 
        "position" => "sticky", "top" => 0percent, "padding" => .5percent, "display" => "inline-flex", 
        "border-bottom-left-radius" => 4pt, "border-bottom-right-radius" => 4pt)
    container::Component{:div}
end

blog_menubutton_class = style("a.blogmenubutton", "border-left" => "4px solid #8833b0", "border-top-right-radius" => 6pt,
    "cursor" => "pointer", "padding" => .5percent, "color" => "#d4cfb0", "font-size" => 20pt, "padding-left" => 1.5percent, "padding-right" => 1.5percent, 
    "transition" => 400ms)
blog_menubutton_class:"hover":["background-color" => "#0a0a0a", "color" => "#854a96", "border-bottom" => "4px solid #854a96", "font-weight" => "bold"]

blog_route = route("/blog") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar("homemen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

latest_route = route("/blog/latest") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar("latestmen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

cats_route = route("/blog/categories") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar("catmen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

series_route = route("/blog/series") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar("sermen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

search_route = route("/blog/search") do c::AbstractConnection
    write!(c, blog_menubutton_class)
    bod = body("mainbody", children = [build_blog_bar()], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end


push!(EmsComputer.ROUTES, blog_route, latest_route, cats_route, series_route, search_route)