function make_header(c::Connection, uri::String = "/images/animated.gif")
    header = divider("header", align = "center", float = "left")
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


function home(c::Connection)
    write!(c, title("thetitle", text = "em's computer !"))
    header = make_header(c)
    body = Component("mainbody", "body")
    style!(body, "background-color" => "#D6CBDA")
    #==
    Header links
    ==#
    main = divider("maindiv")
    main["dark"] = "no"
    main["bselected"] = "postbutton"
    style!(main, "background-color" => "#03DAC6", "margin-top" => "50px",
    "border-radius" => "20px", "padding" => "10px", "margin-left" => "200px",
    "margin-right" => "200px")
    sponsorbttn = img("sponsorbutton", src = "images/icons/sponsoricon.png",
    width = 64, height = 64)
    githubbttn = img("ghbutton", src = "images/icons/ghicon.png",
    width = 64, height = 64)
    ytbttn = img("ytbutton", src = "images/icons/yticon.png",
    width = 64, height = 64)
    medbttn = img("medbutton", src = "images/icons/medic.png",
    width = 64, height = 64)
    lightbttn = img("lightbutton", src = "images/icons/swicol.png")
    twittbutton = img("twittbutton", src = "images/icons/twittico.png",
    width = 64, height = 64)
    twittbutton = img("twittbutton", src = "images/icons/twittico.png",
    width = 64, height = 64)
    linbutton = img("linbutton", src = "images/icons/linkinicon.png",
    width = 64, height = 64)
    linkbuttons = components(sponsorbttn, githubbttn, ytbttn, medbttn,
    twittbutton, linbutton, lightbttn)
    for thisbutton in linkbuttons
        on(c, thisbutton, "mouseover") do cm::ComponentModifier
            cm[thisbutton] = "width" => 75
            cm[thisbutton] = "height" => 75
        end
        on(c, thisbutton, "mouseleave") do cm::ComponentModifier
            cm[thisbutton] = "width" => 64
            cm[thisbutton] = "height" => 64
        end
    end
    on(c, sponsorbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://github.com/sponsors/emmettgb")
        alert!(cm, "redirecting to my sponsors profile (thanks !)")
    end
    on(c, medbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://medium.com/@emmettgb")
        alert!(cm, "redirecting to my medium blog :)")
    end
    on(c, ytbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://www.youtube.com/channel/UCruzXIngBV2dlgjX1_HZRzw")
        alert!(cm, "redirecting to my youtube channel !")
    end
    on(c, githubbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://github.com/emmettgb")
        alert!(cm, "redirecting to my github !")
    end
    on(c, twittbutton, "click") do cm::ComponentModifier
        redirect!(cm, "https://twitter.com/emmettboudgie")
        alert!(cm, "redirecting to em on twitter")
    end
    on(c, linbutton, "click") do cm::ComponentModifier
        redirect!(cm, "https://www.linkedin.com/in/emmett-boudreau-828b2818a/")
        alert!(cm, "redirecting to my linkedin !")
    end
    on(c, lightbttn, "click") do cm::ComponentModifier
        if cm[main]["dark"] != "yes"
            cm[lightbttn] = "src" => "/images/icons/swicold.png"
            style!(cm, main, "background-color" => "#3700B3")
            style!(cm, body, "background-color" => "#36454F")
            cm[main] = "dark" => "yes"
        else
            cm[lightbttn] = "src" => "/images/icons/swicol.png"
            style!(cm, main, "background-color" => "#03DAC6")
            style!(cm, body, "background-color" => "#D6CBDA")
            cm[main] = "dark" => "no"
        end
    end
    button_group = divider("buttongrp", align = "center")
    button_group[:children] = linkbuttons
    push!(header, button_group)
    #==
    Navigation buttons
    ==#
    postsbutton = button("postbutton", text = "my posts")
    repobutton = button("repobutton", text = "repository overview")
    contactbutton = button("contactbttn", text = "contact me")
    projects = button("projbttn", text = "project portfolio")
    collaborate = button("collbttn", text = "collaborate !")
    for comp in components(repobutton, contactbutton, postsbutton,
        collaborate, projects)
        style!(comp, "color" => "white", "border-style" => "none",
        "background-color" => "#107896", "border-radius" => "10px")
        on(c, comp, "mouseover") do cm::ComponentModifier
            if cm[main]["bselected"] == comp.name
                style!(cm, comp, "background-color" => "orange")
            else
                style!(cm, comp, "background-color" => "lightblue")
            end
        end
        on(c, comp, "mouseleave") do cm::ComponentModifier
            if cm[main]["bselected"] == comp.name
                style!(cm, comp, "background-color" => "purple")
            else
                style!(cm, comp, "background-color" => "#107896")
            end
        end
    end
    style!(postsbutton, "color" => "white", "border-style" => "none",
    "background-color" => "purple", "border-radius" => "10px")
    on(c, repobutton, "click") do cm::ComponentModifier
        cm["logo"] = "src" => "/images/animated.gif"
        cm["logo"] = "out" => "true"
        cm[main] = "bselected" => repobutton.name
        for but in linkbuttons
            animate!(cm, but, anim_logoout())
            style!(cm, but, "opacity" => "0%")
        end
        animate!(cm, "logo", anim_logoout())
    end
    navdiv = divider("navdiv", align = "center")
    push!(navdiv, postsbutton, repobutton, projects, collaborate, contactbutton)
    push!(main, navdiv)
    #==
    Home !
    ==#
    home_div = divider("homediv", align = "center")
    greeting = h("greeting", align = "center",
    text = "hi, welcome to em's computer!")
    push!(home_div, greeting)
    push!(main, home_div)
    #==
    Writes
    ==#
    push!(body, header, main)
    write!(c, stylesheet())
    write!(c, body)
end
