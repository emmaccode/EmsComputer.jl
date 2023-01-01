
function home(c::Connection)
    uri::String = "/images/animated.gif"
    write!(c, title("thetitle", text = "em's computer !"))
    write!(c, ToolipsDefaults.sheet("emsstyles"))
    logobg = div("logobg", align = "center")
    style!(logobg, "background" => "transparent", "margin-top" => 5percent,
    "opacity" => 0percent, "transform" => "translateX(20%)", "transition" => 2seconds)
    header = img("emseyes", src = uri, width = 350)
    push!(logobg, header)
    body = Component("mainbody", "body")
    style!(body, "background-color" => "#D6CBDA", "overflow" => "hidden")
    main = divider("maindiv", align = "left")
    style!(main, "background-color" => "#36454F", "margin-top" => 2percent,
    "width" => 20percent, "margin-left" => 40percent, "position" => "absolute",
    "opacity" => 0percent, "transition" => 2seconds, "height" => 0percent,
    "overflow" => "hidden")
    loginstuff = div("loginstuff", align = "left")
    style!(loginstuff, "background" => "transparent")
    unamebox = ToolipsDefaults.textdiv("unamebox", text = "username")
    on(c, unamebox, "click") do cm::ComponentModifier
        if cm[unamebox]["text"] == "username"
            set_text!(cm, unamebox, "")
        end
    end
    pwdbox = ToolipsDefaults.textdiv("pwdbox", text = "")
    style!(unamebox, "color" => "white", "background-color" => "#888C8D", "font-size" => 14pt)
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
        style!(cm, main, "height" => 0percent, "opacity" => "0percent")
        style!(cm, body, "background-color" => "#36454F", "transition" => "2s")
        style!(cm, emsfooter, "opacity" => 0percent)
    end
    push!(loginstuff, loginheading, unamelabel, unamebox, br(), pwdlabel, mainpwdbox,
    signupbutton, skipbutton, loginbutton)
    push!(main, loginstuff)
    emsfooter = div("emsfooter")
    style!(emsfooter, "background" => "transparent",
    "margin-left" => 40percent, "margin-top" => 18percent, "opacity" => 0percent,
    "transition" => 1seconds, "width" => 0percent)
    push!(emsfooter, button("sourcelink", text = "source", href = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "license", href = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "contact", href = "/contact"))
    on(c, "load") do cm::ComponentModifier
        style!(cm, logobg, "opacity" => 100percent, "transform" => "translateX(0%)")
        next!(c, logobg, cm) do cm2::ComponentModifier
            style!(cm2, main, "height" => 29percent, "opacity" => 100percent)
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
