function build_main(c::Connection, cm::ComponentModifier, bod::Component{:body})
    style!(cm, "maindiv", "height" => 0percent, "opacity" => "0percent")
    style!(cm, "mainbody", "background-color" => "#36454F", "transition" => "2.5s")
    remove!(cm, "emsfooter")
    app_panel = section("emsapps")
    searchbox_div::Component{:div} = div("searchb_c")
    style!(searchbox_div, "background-color" => "#888C8D")
    searchinput::Component{:div} = ToolipsDefaults.textdiv("searchinp")
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
            next!(c, bod, cm2) do cm3::ComponentModifier
                
            end
        end
        push!(postbody, img("$(psh.title)-i", src = psh.img, width = 300),
         h("$(psh.title)-t", 2, text = psh.title),
        h("$(psh.title)-st", 4, text = psh.sub))
        push!(app_panel, postbody)
    end
    next!(c, bod, cm) do cm2::ComponentModifier
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
    stylsheet::Component{:sheet} = ToolipsDefaults.sheet("emsstyles")
    stylsheet[:children]["h2"]["color"] = "white"
    stylsheet[:children]["h4"]["color"] = "lightblue"
    stylsheet[:children]["section"]["border-color"] = "gray"
    stylsheet::Component{:sheet}
end

function home(c::Connection)
    uri::String = "/images/animated.gif"
    write!(c, title("thetitle", text = "em's computer !"))
    write!(c, create_styles())
    logobg = div("logobg", align = "center")
    style!(logobg, "background" => "transparent", "margin-top" => 5percent,
    "opacity" => 0percent, "transform" => "translateX(20%)", "transition" => 2seconds,
    "overflow" => "hidden")
    header = img("emseyes", src = uri, width = 350)
    betaemblem = h("betaemblem", 3, text = "open-alpha 0.0.5")
    style!(betaemblem, "color" => "white", "transform" => "translateX(5%)")
    push!(logobg, header, betaemblem)
    body = Component("mainbody", "body")
    style!(body, "background-color" => "#D6CBDA", "overflow" => "hidden",
    "transition" => 8seconds)
    main = divider("maindiv", align = "left")
    style!(main, "background-color" => "#36454F", "margin-top" => 2percent,
    "width" => 20percent, "margin-left" => 40percent, "position" => "absolute",
    "opacity" => 0percent, "transition" => 2seconds, "height" => 0percent,
    "overflow" => "hidden")
    loginstuff = div("loginstuff", align = "left")
    style!(loginstuff, "background" => "transparent")
    unamebox = ToolipsDefaults.textdiv("unamebox", text = "username")
    style!(unamebox, "color" => "white", "background-color" => "#888C8D", "font-size" => 14pt)
    on(c, unamebox, "click") do cm::ComponentModifier
        if cm[unamebox]["text"] == "username"
            set_text!(cm, unamebox, "")
        end
    end
    pwdbox = ToolipsDefaults.textdiv("pwdbox", text = "")
    mainpwdbox = div("mainpwdbox")
    style!(pwdbox, "color" => "white", "background-color" => "#888C8D", "font-size" => 14pt,
    "color" => "#888C8D")
    overbox = div("overbox")
    push!(mainpwdbox, overbox, pwdbox)
    style!(mainpwdbox, "background" => "transparent")
    style!(overbox, "position" => "absolute", "z-index" => "5", "pointer-events" => "none",
    "background" => "transparent")
    on(c, pwdbox, "keyup") do cm::ComponentModifier
        enteredpwd = replace(cm[pwdbox]["rawtext"], "&nbsp;" => " ")
        set_children!(cm, overbox,
        Vector{Servable}([img("ex", src = "/images/icons/heart.png", width = 25) for c in 1:length(enteredpwd)]))
    end
    loginheading = h("loginheading", 1, text = "login")
    style!(loginheading, "color" => "white", "margin-top" => 0px)
    unamelabel = a("unamelabel", text = "username")
    style!(unamelabel, "color" => "lightpink")
    pwdlabel = a("unamelabel", text = "password")
    skipbutton = button("skipbutton", text = "skip")
    style!(skipbutton, "background-color" => "blue", "font-size" => "15pt",
    "width" => 20percent, "margin-top" => 15px, "margin-right" => 5percent,
    "margin-left" => 5percent)
    loginbutton = button("loginbutton", text = "login")
    style!(loginbutton, "background-color" => "green", "font-size" => "15pt",
    "width" => 25percent, "margin-top" => 15px)
    signupbutton = button("loginbutton", text = "join")
    style!(signupbutton, "background-color" => "#5856D6FF", "font-size" => "15pt",
    "width" => 20percent, "margin-top" => 15px, "margin-left" => 20percent)
    style!(pwdlabel, "color" => "lightpink")
    on(c, skipbutton, "click") do cm::ComponentModifier
        build_main(c, cm, body)
    end
    push!(loginstuff, loginheading, unamelabel, unamebox, br(), pwdlabel, mainpwdbox,
    signupbutton, skipbutton, loginbutton)
    push!(main, loginstuff)
    emsfooter = div("emsfooter", align = "center")
    style!(emsfooter, "background" => "transparent",
     "margin-top" => 30percent, "opacity" => 0percent,
    "transition" => 1seconds, "width" => 0percent, "position" => "absolute")
    push!(emsfooter, button("sourcelink", text = "source", onaction = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "license", onaction = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "contact", onaction = "/contact"))
    on(c, "load") do cm::ComponentModifier
        style!(cm, logobg, "opacity" => 100percent, "transform" => "translateX(0%)")
        next!(c, logobg, cm) do cm2::ComponentModifier
            style!(cm2, main, "height" => 31percent, "opacity" => 100percent)
            next!(c, main, cm2) do cm3::ComponentModifier
                style!(cm3, emsfooter, "opacity" => 100percent, "width" => 100percent)
            end
        end
    end
    #==
    Writes
    ==#
    push!(body, logobg, main, emsfooter)
    write!(c, body)
end
