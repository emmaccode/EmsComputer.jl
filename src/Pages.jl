function make_header(c::Connection, uri::String = "/images/animated.gif")
    header = div("header", align = "center", float = "left")
    header["top-margin"] = "100px"
    logo = img("logo", src = uri)
    logo[:class] = "logo"
    logo["out"] = "false"
    on(c, logo, "animationend") do cm::ComponentModifier
        if cm[logo]["out"] == "true"
            remove!(cm, logo)
        end
    end
    push!(header, logo)
    header
end

function build_main(c::Connection, cm::ComponentModifier, bod::Component{:body})
    style!(cm, "maindiv", "height" => 0percent, "opacity" => "0percent")
    style!(cm, "mainbody", "background-color" => "#36454F")
    remove!(cm, "emsfooter")
    app_panel = section("emsapps")
    searchbox_div::Component{:div} = div("searchb_c")
    style!(searchbox_div, "background-color" => "#888C8D")
    searchinput::Component{:div} = Components.textdiv("searchinp")
    style!(searchinput, "color" => "white", "background-color" => "#888C8D")
    push!(searchbox_div, searchinput)
    style!(app_panel, "background-color" => "#320064", "border-color" => "#141414")
    push!(app_panel, searchbox_div)
    for post_dir in readdir("public/content/posts")
        psh::Post = Post("public/content/posts/" * post_dir)
        postbody = section("postbody")
        on(c, postbody, "click") do cm2::ComponentModifier
            style!(cm2, "mainbody", "background-color" => "#141414")
            style!(cm2, "maindiv", "height" => 0percent, "opacity" => 0percent)
            style!(cm2, "emseyes", "transform" => "translateX(-300%)")
            remove!(cm2, "betaemblem")
            next!(c, cm2, bod) do cm3::ComponentModifier
                
            end
        end
        push!(postbody, img("$(psh.title)-i", src = psh.img, width = 300),
         h2("$(psh.title)-t", text = psh.title),
        h4("$(psh.title)-st", text = psh.sub))
        push!(app_panel, postbody)
    end
    next!(c, cm, bod) do cm2::ComponentModifier
        set_children!(cm2, "maindiv", [app_panel])
        cm2["emseyes"] = "src" => "/images/animated.gif"
        style!(cm2, "maindiv", "background" => "transparent", "height" => 100percent,
        "width" => 50percent, "opacity" => 100percent, "margin-left" => 25percent,
        "margin-top" => 15px)
        style!(cm2, "emseyes", "transform" => "scale(.7)", "transition" => 2seconds,
        "margin-top" => 5px)
        style!(cm2, "mainbody", "overflow-y" => "scroll")
    end
end

function create_styles()
    stylsheet::Component{:sheet} = Component{:sheet}("emsstyles")
    button_style = style("button", "padding" => 10px, "font-weight" => "bold", "font-size" => 11pt, 
    "color" => "white", "background-color" => "#481d4a", "border-radius" => 3px, 
    "border" => "1px solid #1e1e1e", "cursor" => "pointer")
    push!(stylsheet, button_style)
    stylsheet::Component{:sheet}
end

