USER_IDS::Dict{String, String} = Dict{String, String}()

function generate_user_id()
    user_id = Components.gen_ref(8)
    if user_id in values(USER_IDS)
        generate_user_id()
    end
    user_id::String
end

function get_client_id(c::AbstractConnection)
    ip::String = get_ip(c)
    if haskey(USER_IDS, ip)
        return(USER_IDS[ip])
    else
        @warn "this should never happen..."
        throw(KeyError(ip))
    end
end

mutable struct ClientComputer{logged <: Any}
    windows::Vector{String}
    open_window::UInt8
    apps::Vector{UInt8}
    username::String
    userid::String
    function ClientComputer(userid::String, username::String = "GUEST")
        new{username != "GUEST"}([], 0, [1], username, userid)
    end
end

function getindex(vec::Vector{ClientComputer}, id::String)
    found = findfirst(client::ClientComputer -> client.userid == id, vec)
    if isnothing(found)
        throw(KeyError(id))
    end
    vec[found]::ClientComputer
end

LOGO_URI::String = "/images/animated.gif"

mutable struct ColorPagesApp{T <: Any}
    appname::String
    icon::String
    color::String
end

APPS = [ColorPagesApp{:posts}("posts", LOGO_URI, "#1e1e1e")]

function authenticate_client!(c::AbstractConnection, username::String = "GUEST")
    new_id::String = generate_user_id()
    push!(USER_IDS, get_ip(c) => new_id)
    push!(c[:clients], ClientComputer(userid, username))
    userid::String
end

write_style_defaults!(c::AbstractConnection) = write!(c, title("thetitle", text = "em's computer !"), create_styles())




function build_logo_header()
    header = img("emseyes", src = LOGO_URI, width = 350)
    betaemblem = h3("betaemblem", text = "open-alpha")
    style!(betaemblem, "color" => "white", "transform" => "translateX(5%)")
    logobg = div("logobg", align = "center", children = [header, betaemblem])
    style!(logobg, "background" => "transparent", "margin-top" => 5percent,
        "opacity" => 0percent, "transform" => "translateX(20%)", "transition" => 1500ms,
        "overflow" => "hidden")
    logobg::Component{:div}
end

function build_splash(c::AbstractConnection)
    write_style_defaults!(c)
    logobg::Component{:div} = build_logo_header()
    unamebox::Component{:div} = Components.textdiv("unamebox", text = "")
    style!(unamebox, "background-color" => "white", "padding" => 6px, "color" => "#1e1e1e", 
    "border-radius" => 2px)
    pwdbox = Components.textdiv("pwdbox", text = "")
    style!(pwdbox, "color" => "white", "background-color" => "#888C8D", "font-size" => 14pt,
        "padding" => 4px, "opacity" => 0percent)
    overbox = div("overbox")
    style!(overbox, "position" => "absolute", "z-index" => "5", "pointer-events" => "none",
    "background" => "transparent", "padding" => 6px, 
    "min-height" => 1.5percent, "transition" => 200ms)
    mainpwdbox = div("mainpwdbox", children = [overbox, pwdbox])
    style!(mainpwdbox, "background-color" => "white", "border-radius" => 2px)
    on(c, pwdbox, "keyup") do cm::ComponentModifier
        enteredpwd = replace(cm[pwdbox]["text"], "\n" => "")
        if length(enteredpwd) == 0
            set_text!(cm, overbox, "")
            return
        end
        set_children!(cm, overbox,
        Vector{Servable}([img("ex", src = "/images/icons/heart.png", width = 16) for c in 1:length(enteredpwd)]))
    end
    loginheading = h1("loginheading", text = "login")
    style!(loginheading, "color" => "white")
    unamelabel = a("unamelabel", text = "username")
    style!(unamelabel, "color" => "white", "font-size" => 13pt)
    pwdlabel = a("unamelabel", text = "password")
    style!(pwdlabel, "color" => "white", "font-size" => 13pt, "margin-bottom" => 2px)
    skipbutton = button("skipbutton", text = "skip")
    on(c, skipbutton, "click") do cm::ComponentModifier
        new_user_id = generate_user_id()
        push!(USER_IDS, get_ip(c) => new_user_id)
        push!(c[:clients], ClientComputer(new_user_id))
        style!(cm, "maindiv", "height" => 0percent, "opacity" => 0percent)
        style!(cm, "overbox", "opacity" => 0percent)
        style!(cm, "mainbody", "background-color" => "#36454F")
        style!(cm, "emsfooter", "top" => 100percent, "opacity" => 0percent)
        cm["emseyes"] = "src" => "/images/animated.gif"
        style!(cm, "logobg", "opacity" => 0percent, "transform" => translateX(-10percent), "transtion" => 2seconds)
        next!(c, cm, "logobg") do cm2::ComponentModifier
            remove!(cm2, "emsfooter")
            remove!(cm2, "maindiv")
            remove!(cm2, "logobg")
            computer = build_computer(c, c[:clients][new_user_id])
            style!(computer, "opacity" => 0percent, "transition" => 500ms)
            append!(cm2, "mainbody", computer)
            on(cm2, 300) do cl
                style!(cl, "computer-main", "opacity" => 100percent)
            end
        end
    end
    loginbutton = button("loginbutton", text = "login")
    style!(loginbutton, "margin-left" => 3px, "margin-right" => 3px)
    signupbutton = button("signupbutton", text = "join")
    style!(signupbutton, "min-width" => 45percent, "background-color" => "green")
    button_box = div("button-box", children = [skipbutton, loginbutton, signupbutton], align = "center")
    style!(button_box, "margin-top" => 30px)
    loginstuff::Component{:div} = div("loginstuff", align = "left", children = [loginheading, unamelabel, unamebox, br(),
        pwdlabel, mainpwdbox, button_box])
    style!(loginstuff, "background" => "transparent", "margin-top" => 5px)
    main::Component{:div} = div("maindiv", align = "left", children = [loginstuff])
    style!(main, "background-color" => "#36454F", "margin-top" => 2percent,
        "width" => 20percent, "left" => 35percent, "position" => "absolute",
        "opacity" => 0percent, "transition" => 1seconds, "height" => 0percent,
        "overflow" => "hidden", "padding" => 9px, "border-radius" => 3px, "border" => "2px solid #0f0e0f")
    emsfooter = build_splash_footer(c)
    main_body::Component{:body} = Component{:body}("mainbody", children = [logobg, main, emsfooter])
    style!(main_body, "background-color" => "#D6CBDA", "overflow" => "hidden",
        "transition" => 850ms)
    on(c, 150) do cm::ComponentModifier
        style!(cm, logobg, "opacity" => 100percent, "transform" => "translateX(0%)")
        next!(c, cm, logobg) do cm2::ComponentModifier
            style!(cm2, main, "height" => 35percent, "opacity" => 100percent, "width" => 30percent, "left" => 36percent)
            next!(c, cm2, main) do cm3::ComponentModifier
                style!(cm3, emsfooter, "opacity" => 100percent, "width" => 30percent, "left" => 36percent)
            end
        end
    end
    write!(c, main_body)
end

function build_splash_footer(c::AbstractConnection)
    source_button = button("sourcelink", text = "source")
    license_button = button("licenselink", text = "licensing")
    about_button = button("buttonlink", text = "about")
    emsfooter = div("emsfooter", align = "center", children = [source_button, license_button, about_button])
    style!(emsfooter, "background" => "transparent",
     "margin-top" => 35percent, "opacity" => 0percent,
    "transition" => 700ms, "width" => 30percent, "position" => "absolute", "left" => 0percent)
    emsfooter::Component{:div}
end

function on_start(ext::Toolips.QuickExtension{:clients}, data::Dict{Symbol, Any}, 
    routes::Vector{<:AbstractRoute})
    push!(data, :clients => Vector{ClientComputer}())
end

function build_computer(c::AbstractConnection, computer::ClientComputer)
    boot_button = button("bootbutton", text = "click to boot")
    style!(boot_button, "margin-top" => 25percent, "margin-right" => 20percent, "width" => 30percent, "background-color" => "#0d0c0b", 
    "border" => "2px solid white", "border-radius" => 2px)
    on(c, boot_button, "click") do cm::ComponentModifier
        remove!(cm, "bootbutton")
        style!(cm, "computer-main", "background-color" => "#A63855", "transition" => 3seconds)
        next!(c, cm, "computer-main") do cm::ComponentModifier
            if ~("colorpages-menu" in cm)
                append!(cm, "computer-main", make_windowmenu(c, computer))
            end
        end
    end
    computer_window = div("computer-main", children = boot_button, align = "right")
    style!(computer_window, "border" => "10px solid #e6d897", "border-radius" => 6px, "min-width" => 85percent, "min-height" => 80percent, 
    "margin" => 5percent, "background-color" => "#0d0c0b", "max-height" => 80percent, "max-width" => 85percent, "overflow" => "hidden")
    computer_window
end

close_appname = h1("applabel", text = "close")
style!(close_appname, "color" => "white", "font-size" => 12pt, "font-weight" => "bold")
close_appimage = img("appimage", width = 64, src = LOGO_URI)
close_app_button = div("appclose", children = [close_appimage, close_appname])
style!(close_app_button, "padding" => 5px, "cursor" => "pointer")

on(SESSION, "close_appmenu") do cm::ComponentModifier
    style!(cm, "colorpages-menu", "width" => 4percent, "padding" => "0px")
    set_children!(cm, "colorpages-menu", Vector{AbstractComponent}())
    cm["colorpages-menu"] = "expanded" => "0"
end
on("close_appmenu", close_app_button, "click")

function make_windowmenu(c::AbstractConnection, computer::ClientComputer)
    bar = div("colorpages-menu", align = "left", expanded = 0)
    style!(bar, "display" => "inline-block")
    on(c, bar, "click") do cm::ComponentModifier
        if cm["colorpages-menu"]["expanded"] == "0"
            style!(cm, "colorpages-menu", "width" => 100percent, "padding" => 20px)
            set_children!(cm, "colorpages-menu", 
            Vector{AbstractComponent}([close_app_button, (make_app_preview(c, app) for app in APPS) ...]))
            cm["colorpages-menu"] = "expanded" => "1"
        end
    end
    style!(bar, "left" => 200percent, "background-color" => "#0c0b0d", "height" => 85percent, "width" => 4percent, "transition" => 700ms)
    bar
end

function make_app_preview(c::AbstractConnection, app::ColorPagesApp{<:Any})
    name = h1("applabel", text = app.appname)
    style!(name, "color" => "white", "font-size" => 12pt, "font-weight" => "bold")
    image = img("appimage", width = 64, src = app.icon)
    preview = div("app$(app.appname)", children = [image, name])
    on(c, preview, "dblclick") do cm::ComponentModifier
        app_window = make_windowmenu(c, app)
        insert!(cm, "computer-main", 1, app_window)
        set_children!(cm, "colorpages-menu", Vector{AbstractComponent}())
        cm["colorpages-menu"] = "expanded" => "0"
        on(c, cm, 500) do cm2
            style!(cm2, "colorpages-menu", "width" => 4percent, "padding" => "0px")
            style!(cm2, app_window, "width" => 96percent, "display" => "inline-block")
        end
    end
    style!(preview, "padding" => 5px, "cursor" => "pointer")
    preview
end

#A63855
computer_main = route("/") do c::AbstractConnection
    if haskey(USER_IDS, get_ip(c))
        computer = c[:clients][get_client_id(c)]
        write!(c, build_computer(c, computer))
    else
        build_splash(c)
    end
end