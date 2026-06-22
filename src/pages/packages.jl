function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:packages})
    package_previews = [begin
        make_package_preview(c, packagen)
    end for packagen in readdir("packageinfo")]
    main_app = div("mainpackages", children = package_previews)
    menu = make_base_windowmenu(c, app, main_app)
    menu[:align] = "left"
    menu
end

function make_package_preview(c::AbstractConnection, name::String)
    raw_data = read("packageinfo/" * name, String)
    name = replace(name, ".txt" => ".jl")
    splts = split(raw_data, "---")
    cover_img = img(src = splts[3] * "?raw=true", width = 175)
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
        popup = make_package_popup(name)
    end
    preview::Component{:div}
end

function make_package_popup(name::String)
    raw_data = read("packageinfo/" * name, String)
    splts = split(raw_data, "---")
end