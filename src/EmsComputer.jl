
function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end

lfade = Animation("fade_left", length = 4.0)
lfade[:from] = "opacity" => "0%"
lfade[:to] = "opacity" => "100%"
lfade[:from] = "transform" => "translateX(100%)"
lfade[:to] = "transfrom" => "translateX(0%)"

logo_style = Style("img")
logo = img("logo", src = "https://i.postimg.cc/W3m15ssc/animated.gif")
logo_style[:width] = "350"

animate!(logo_style, lfade)
style!(logo, logo_style)

heading1_style = Style("h1")
heading1_style["color"] = "pink"

header_css = [lfade, logo_style, heading1_style]
header = Toolips.div("header", [logo])

header[:align] = "center"
header["top-margin"] = "100px"


hello_world = route("/") do c
    for s in header_css
        write!(c, s)
    end
    write!(c, header)
    write!(c, "<div align = \"center\">")
    write!(c, "</br></br><h1>")
    write!(c, "welcome to em's computer.</br> This website is still being developed.</h1>")
end

fourofour = route("404") do c
    write!(c, p("404", text = "404, not found!"))
end

rs = routes(hello_world, fourofour)
main(rs)
