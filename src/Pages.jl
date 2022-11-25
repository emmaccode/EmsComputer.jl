
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
    unamebox = ToolipsDefaults.textdiv("unamebox")
    pwdbox = ToolipsDefaults.textdiv("pwdbox")
    style!(unamebox, "color" => "white", "background-color" => "#888C8D")
    style!(pwdbox, "color" => "white", "background-color" => "#888C8D")
    loginheading = h("loginheading", 1, text = "login")
    style!(loginheading, "color" => "white", "margin-top" => 0px)
    unamelabel = a("unamelabel", text = "username")
    style!(unamelabel, "color" => "lightpink")
    pwdlabel = a("unamelabel", text = "password")
    insidebutton = button("insidebutton", text = "inside")
    style!(insidebutton, "background-color" => "orange", "font-size" => "15pt",
    "width" => 25percent, "margin-top" => 15px)
    skipbutton = button("skipbutton", text = "skip")
    style!(skipbutton, "background-color" => "blue", "font-size" => "15pt",
    "width" => 20percent, "margin-top" => 15px, "margin-right" => 5percent)
    loginbutton = button("loginbutton", text = "login")
    style!(loginbutton, "background-color" => "green", "font-size" => "15pt",
    "width" => 25percent, "margin-top" => 15px)
    signupbutton = button("loginbutton", text = "join")
    style!(signupbutton, "background-color" => "blue", "font-size" => "15pt",
    "width" => 20percent, "margin-top" => 15px, "margin-left" => 5percent)
    style!(pwdlabel, "color" => "lightpink")
    push!(loginstuff, loginheading, unamelabel, unamebox, br(), pwdlabel, pwdbox,
    insidebutton, signupbutton, skipbutton, loginbutton)
    push!(main, loginstuff)
    emsfooter = div("emsfooter")
    style!(emsfooter, "background" => "transparent", "position" => "absolute",
    "margin-left" => 40percent, "margin-top" => 17percent)
    push!(emsfooter, p("hethet", text = "hello"))
    on(c, "load") do cm::ComponentModifier
        style!(cm, logobg, "opacity" => 100percent, "transform" => "translateX(0%)")
        next!(c, logobg, cm) do cm::ComponentModifier
            style!(cm, main, "height" => 29percent, "opacity" => 100percent)
        end
    end
    #==
    Writes
    ==#
    push!(body, logobg, main, emsfooter)
    write!(c, body)
end
