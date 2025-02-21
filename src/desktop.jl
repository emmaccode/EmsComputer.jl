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
    username::String
    userid::String
    function ClientComputer(userid::String, username::String = "GUEST")
        new{username != "GUEST"}([], 0, username, userid)
    end
end

function authenticate_client!(c::AbstractConnection, username::String = "GUEST")
    new_id::String = generate_user_id()
    push!(USER_IDS, get_ip(c) => new_id)
    push!(c[:clients], ClientComputer(userid, username))
    userid::String
end

function main_desktop(c::AbstractConnection)

end

write_style_defaults!(c::AbstractConnection) = write!(c, title("thetitle", text = "em's computer !"), create_styles())

LOGO_URI::String = "/images/animated.gif"

function build_splash(c::AbstractConnection)
    write_style_defaults!(c)
    header = img("emseyes", src = LOGO_URI, width = 350)
    betaemblem = h3("betaemblem", text = "open-alpha")
    style!(betaemblem, "color" => "white", "transform" => "translateX(5%)")
    logobg = div("logobg", align = "center", children = [header, betaemblem])
    style!(logobg, "background" => "transparent", "margin-top" => 5percent,
        "opacity" => 0percent, "transform" => "translateX(20%)", "transition" => 2seconds,
        "overflow" => "hidden")
    unamebox = Components.textdiv("unamebox", text = "username")
    pwdbox = Components.textdiv("pwdbox", text = "")
    style!(pwdbox, "color" => "white", "background-color" => "#888C8D", "font-size" => 14pt,
        "color" => "#888C8D", "opacity" => 0percent)
    overbox = div("overbox")
    style!(overbox, "position" => "absolute", "z-index" => "5", "pointer-events" => "none",
    "background" => "transparent")
    mainpwdbox = div("mainpwdbox", children = [overbox, pwdbox])
    style!(mainpwdbox, "background" => "transparent")
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
    style!(loginheading, "color" => "white", "margin-top" => 0px)
    unamelabel = a("unamelabel", text = "username")
    style!(unamelabel, "color" => "lightpink")
    pwdlabel = a("unamelabel", text = "password")
    skipbutton = button("skipbutton", text = "skip")
    on(c, skipbutton, "click") do cm::ComponentModifier
        # build guest computer here
    end
    loginbutton = button("loginbutton", text = "login")
    signupbutton = button("loginbutton", text = "join")
    loginstuff::Component{:div} = div("loginstuff", align = "left", children = [loginheading, unamelabel, unamebox, br(),
        pwdlabel, mainpwdbox, signupbutton, skipbutton, loginbutton])
    style!(loginstuff, "background" => "transparent")
    main::Component{:div} = div("maindiv", align = "left", children = [loginstuff])
    style!(main, "background-color" => "#36454F", "margin-top" => 2percent,
        "width" => 20percent, "margin-left" => 40percent, "position" => "absolute",
        "opacity" => 0percent, "transition" => 2seconds, "height" => 0percent,
        "overflow" => "hidden", "padding" => 7px)
    emsfooter = div("emsfooter", align = "center")
    style!(emsfooter, "background" => "transparent",
     "margin-top" => 30percent, "opacity" => 0percent,
    "transition" => 1seconds, "width" => 0percent, "position" => "absolute")
    push!(emsfooter, button("sourcelink", text = "source", onaction = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "license", onaction = "https://github.com/emmettgb/EmsComputer.jl"))
    push!(emsfooter, button("sourcelink", text = "contact", onaction = "/contact"))
    main_body::Component{:body} = Component{:body}("mainbody", children = [logobg, main, emsfooter])
    style!(main_body, "background-color" => "#D6CBDA", "overflow" => "hidden",
        "transition" => 850ms)
    on(c, 50) do cm::ComponentModifier
        style!(cm, logobg, "opacity" => 100percent, "transform" => "translateX(0%)")
        next!(c, cm, logobg) do cm2::ComponentModifier
            style!(cm2, main, "height" => 31percent, "opacity" => 100percent)
            next!(c, cm2, main) do cm3::ComponentModifier
                style!(cm3, emsfooter, "opacity" => 100percent, "width" => 100percent)
            end
        end
    end
    write!(c, main_body)
end

function on_start(ext::Toolips.QuickExtension{:clients}, data::Dict{Symbol, Any}, 
    routes::Vector{<:AbstractRoute})
    push!(data, :clients => Vector{ClientComputer}())
end

computer_main = route("/") do c::AbstractConnection
    if haskey(USER_IDS, get_ip(c))

    else
        build_splash(c)
    end
end