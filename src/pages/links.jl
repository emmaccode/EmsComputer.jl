function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:links})
    menu = make_base_windowmenu(c, app, LINKS_MAIN)
end


function build_link_element(name::AbstractString, link::AbstractString, img_path::AbstractString)
    link_image = img(src = img_path, width = 150)
    image_wrapper = span("-", children = [link_image])
    lnk_name = a(text = name)
    style!(lnk_name, "color" => "#362835", "font-weight" => "bold", "font-size" => 16pt, "margin-left" => 30px)
    lnk_over = div("-", children = [image_wrapper, lnk_name], onclick = "'window.location.href = \"$link\";'")
    style!(lnk_over, "user-select" => "none", "cursor" => "pointer", "padding" => 2percent, "border" => "4px solid black", 
        "background-color" => "#cccbca")
    lnk_over::Component{:div}
end

LINKS_MAIN = begin
    linkfile = read("public/links.txt", String)
    link_elements = Vector{AbstractComponent}()
    for linksplit in split(linkfile, "\n")
        if ~(contains(linksplit, "|=|"))
            continue
        end
        splts = split(linksplit, "|=|")
        push!(link_elements, build_link_element(splts[1], splts[2], splts[3]))
    end
    links_main = div("linksmain", children = link_elements)
end