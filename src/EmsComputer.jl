
function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end


rfadem = Animation("fade_right", length = 0.5)
rfadem[:from] = "opacity" => "0%"
rfadem[:to] = "opacity" => "100%"
rfadem[:from] = "transform" => "translateX(200%)"
rfadem[:to] = "transfrom" => "translateX(100%)"

ul_style = Style("ul")
ul_style[:position] = "relative"
ul_style[:transform] = "rotate(0deg) skew(0deg, 10deg)"

list_item = Style("list-item")
list_item[:background] = "#000"
list_item[:color] = "#ffffff"
list_item["text-align"] = "center"
list_item[:height] = "2.5em"
list_item[:width] = "4em"
list_item["vertical-align"] = "middle"
list_item["line-height"] = "2.5em"
list_item["border-bottom"] = "1px"
list_item[:position] = "relative"
list_item[:display] = "block"
list_item["box-shadow"] = "-2em 1.5em 0 #e1e1e1"
lihover = Style("list-item:hover")
lihover[:background] = "#FFC0CB"
lihover[:color] = "#fffcfb"
lihover[:transform] = "translate(.9em, -.9em)"
lihover[:transition] = "all .25s linear"
lihover["box-shadow"] = "-2em 2em 0 #e1e1e1"

lfade = Animation("fade_left", length = 2.8)
lfade[:from] = "opacity" => "0%"
lfade[:to] = "opacity" => "100%"
lfade[:from] = "transform" => "translateX(100%)"
lfade[:to] = "transform" => "translateX(0%)"

heading1_style = Style("h1")
heading1_style["color"] = "pink"

heading2_style = Style("h2")
heading2_style["color"] = "#85H456"

logo_style = Style("img")
logo_style[:width] = "250"
animate!(logo_style, lfade)

head_css = Component("hcss", "head")

header = divider("header", align = "center")
header["top-margin"] = "100px"

logo = img("logo", src = "/public/images/animated.gif")
style!(logo, logo_style)

coolscroll = Animation("scrolling", length = 25.5, iterations = 30)
coolscroll[0] = "transform" => "translateX(0%)"
coolscroll[50] = "transform" => "translateX(100%)"
coolscroll[100] = "transform" => "translateX(0%)"

hwscr = Style("h2.scroller")
animate!(hwscr, coolscroll)
hwscr[:color] = "lightblue"

scheading = h("scheading", 2, text = "this website is under development")
style!(scheading, hwscr)
push!(header, logo)

hello_world = route("/") do c
    write!(c, lfade)
    write!(c, heading1_style)
    write!(c, heading2_style)
    write!(c, logo_style)
    write!(c, coolscroll)
    write!(c, hwscr)
    write!(c, header)
    write!(c, scheading)
end

fourofour = route("404") do c
    write!(c, header)
    write!(c, heading1_style)
    write!(c, heading2_style)
    write!(c, h("4041", 1, text = "404"))
    write!(c, h("4042", 2, text = "It looks like something went wrong."))
end

rs = routes(hello_world, fourofour)
main(rs)
