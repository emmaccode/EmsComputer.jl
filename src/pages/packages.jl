function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:packages})
    package_previews = [begin
        make_package_preview(c, packagen)
    end for packagen in readdir("packageinfo")]
    main_app = div("mainpackages", children = package_previews)
    menu = make_base_windowmenu(c, app, main_app)
    style!(menu, "overflow-x" => "hidden", "overflow-y" => "scroll")
    menu[:align] = "left"
    menu
end

function make_package_preview(c::AbstractConnection, name::String)
    raw_data = read("packageinfo/" * name, String)
    name = replace(name, ".txt" => ".jl")
    splts = split(raw_data, "---")
    cover_img = img(src = splts[3], width = 175)
    img_wrapper = div("-", children = [cover_img], align = "center")
    title = div("-", text = name)
    description = div("-", text = splts[2])
    style!(title, "background-color" => "white", "font-weight" => "bold", 
        "padding" => 1percent, "display" => "flex", "width" => 100percent)
    style!(description, "background-color" => "#8c2986", "padding" => 1percent, 
        "display" => "flex", "width" => 100percent)
    info_wrapper = div("-", children = [title, description])
    style!(info_wrapper, "margin-top" => 40px, "width" => 100percent)
    preview = div("$name-preview", children = [img_wrapper, info_wrapper])
    style!(preview, "background-color" => "#a88da7", "padding" => 4percent, 
        "border-radius" => 3pt, "border" => "2px solid #1e1e1e", "cursor" => "pointer")
    on(c, preview, "click") do cm::ComponentModifier
        if "popup" in cm
            return
        end
        popup = make_package_popup(name)
        append!(cm, "mainbody", popup)
    end
    preview::Component{:div}
end

function make_package_popup(name::String)
    raw_data = read("packageinfo/" * replace(name, ".jl" => ".txt"), String)
    splts = split(raw_data, "---")
    desc = splts[1]
    close_button = div("close", text = "close")
    style!(close_button, "background-color" => "darkred", "color" => "white")
    img_url = splts[3]
    cov_img = img(src = splts[3], width = 150)
    lnk = replace(splts[4], "\n" => "")
    img_wrap = div("-", children = [cov_img], align = "center", style = "padding:1%;")
    descript = div("-", text = desc)
    style!(descript, "background-color" => "white", "padding" => 1.5percent)
    link = div("ecolink", text = "view ecosystem")
    style!(link, "padding" => 1.5percent, "background-color" => "lightblue", 
        "color" => "white", "cursor" => "pointer")
    on(link, "click") do cl::ClientModifier
        redirect!(cl, "https://github.com/$lnk")
    end
    on(cl -> remove!(cl, "popup"), close_button, "click")
    popup = div("popup", children = [close_button, img_wrap, descript, link])
    style!(popup, "position" => "absolute", "z-index" => 25, "width" => 40percent, 
        "left" => 30percent, "top" => 30percent, "background-color" => "#1e1e1e", 
        "border-radius" => 4pt, "border" => "2px solid black")
    popup::Component{:div}
end