function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:software})
    software_previews = [begin
        make_software_preview(data)
    end for data in split(read("public/software.txt", String), "--==--")]
    main_app = div("mainsoftware", children = software_previews)
    menu = make_base_windowmenu(c, app, main_app)
    style!(menu, "overflow-x" => "hidden", "overflow-y" => "scroll")
    menu[:align] = "left"
    menu
end

function make_software_preview(data::AbstractString)
    splts = split(data, "---")
    software_name = replace(splts[1], "\n" => "")
    cover_img = img(src = splts[3], width = 150)
    img_wrapper = div("-", children = [cover_img], align = "center")
    style!(img_wrapper, "padding" => 2percent, "background-color" => "#1e1e1e", "border-radius" => 4pt)
    namebox = div("-", text = software_name)
    style!(namebox, "padding" => 2percent, "font-size" => 26pt, "color" => "#09091f")
    desc = div("-", text = splts[2])
    style!(desc, "color" => "white", "font-size" => 15pt)
    preview = div("popup", children = [img_wrapper, 
        namebox, desc])
    on(preview, "click") do cl
        redirect!(cl, "/$(lowercase(software_name))")
    end
    style!(preview, "border-radius" => 5pt, "padding" => 10percent, 
        "background-color" => "#885696", "cursor" => "pointer", "margin" => 10px, 
        "border" => "2px solid #1e1e1e")
    preview
end