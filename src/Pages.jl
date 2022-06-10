function make_header()
    header = divider("header", align = "center")
    header["top-margin"] = "100px"
    logo = img("logo", src = "/images/animated.gif")
    style!(logo, logo_style)
    push!(header, logo)
    header
end


function home(c::Connection)
    header = make_header()
    scheading = h("scheading", 2, text = "this website is under development")
    style!(scheading, hwscr)
    write!(c, lfade)
    write!(c, logo_style)
    write!(c, coolscroll)
    write!(c, hwscr)
    write!(c, header)
    write!(c, scheading)
    smallgreet = a("smallgreet", text = """Hello, welcome to my new website, I am still
    working on the web-development framework beneath this, and using this
    project as a refinement motivator. Thank you for checking
    it out. If you are running this server locally, I highly suggest trying
    some of the methods included in dev.jl!""")
    style!(smallgreet, graytxt)
    write!(c, smallgreet)
end
