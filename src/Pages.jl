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

    #==
    Header links
    ==#
    main = divider("maindiv")
    main["dark"] = "no"
    style!(main, "background-color" => "#03DAC6", "margin-top" => "50px",
    "border-radius" => "20px", "padding" => "10px")
    sponsorbttn = img("sponsorbutton", src = "images/icons/sponsoricon.png",
    width = 64, height = 64)
    githubbttn = img("ghbutton", src = "images/icons/ghicon.png",
    width = 64, height = 64)
    ytbttn = img("ytbutton", src = "images/icons/yticon.png",
    width = 64, height = 64)
    medbttn = img("medbutton", src = "images/icons/medic.png",
    width = 64, height = 64)
    lightbttn = img("lightbutton", src = "images/icons/swicol.png")
    linkbuttons = components(sponsorbttn, githubbttn, ytbttn, medbttn, lightbttn)
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
        alert!(cm, "redirecting to my sponsors profile (thanks!)")
    end
    on(c, medbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://medium.com/@emmettgb")
        alert!(cm, "redirecting to my medium blog :)")
    end
    on(c, ytbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://www.youtube.com/channel/UCruzXIngBV2dlgjX1_HZRzw")
        alert!(cm, "redirecting to my youtube channel!")
    end
    on(c, githubbttn, "click") do cm::ComponentModifier
        redirect!(cm, "https://github.com/emmettgb")
        alert!(cm, "redirecting to my github!")
    end
    on(c, lightbttn, "click") do cm::ComponentModifier
        if cm[main]["dark"] != "yes"
            cm[lightbttn] = "src" => "/images/icons/swicold.png"
            style!(cm, main, "background-color" => "#3700B3")
            cm[main] = "dark" => "yes"
        else
            cm[lightbttn] = "src" => "/images/icons/swicol.png"
            style!(cm, main, "background-color" => "#03DAC6")
            cm[main] = "dark" => "no"
        end
    end
    button_group = divider("buttongrp", align = "center")
    push!(button_group, sponsorbttn, githubbttn, ytbttn, medbttn, lightbttn)
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
            style!(cm, comp, "background-color" => "lightblue")
        end
        on(c, comp, "mouseleave") do cm::ComponentModifier
            style!(cm, comp, "background-color" => "#107896")
        end
    end
    on(c, repobutton, "click") do cm::ComponentModifier
        cm["logo"] = "src" => "/images/animated.gif"
        cm["logo"] = "out" => "true"
        for but in linkbuttons
            animate!(cm, but, anim_logoout())
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
    Audio test
    ==#
    audioc = Component("myaud","audio controls")
    audioc["src"] = "media/testaudio.ogg"
    push!(main, audioc)
    #==
    Writes
    ==#
    write!(c, stylesheet())
    write!(c, header)
    write!(c, button_group)
    write!(c, main)
end
