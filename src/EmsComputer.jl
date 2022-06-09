function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end

logo = img("logo", src = "https://i.ibb.co/NZhMDn8/animated.gif")
lfade = Animation("fade_left")
lfade[:from] = "opacity" => "%0"
lfade[:to] = "opacity" => "%100"
logo_style = Style("img")
animate!(logo_style, lfade)
style!(logo, logo_style)
heading_style = Style("h1")
heading_style["color"] = "pink"
header_css = [lfade, logo_style, heading_style]
header = Toolips.div("header", [logo])
header[:align] = "center"

hello_world = route("/") do c
    for s in header_css
        write!(c, s)
    end
    write!(c, header)
    write!(c, "<h1>")
    for char in "welcome to em's computer"
        write!(c, string(char))
        sleep(.1)
    end
    write!(c, "</h1>")
end

fourofour = route("404") do c
    write!(c, p("404", text = "404, not found!"))
end
rs = routes(hello_world, fourofour)
main(rs)
