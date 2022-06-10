ul_style = Style("ul")
ul_style[:position] = "relative"
ul_style[:transform] = "rotate(0deg) skew(0deg, 10deg)"

list_item = Style("list-item")
list_item[:background] = "#fffff"
list_item[:color] = "lightgreen"
list_item["text-align"] = "center"
list_item[:height] = "2.5em"
list_item[:width] = "4em"
list_item["vertical-align"] = "middle"
list_item["line-height"] = "2.5em"
list_item[:position] = "relative"
list_item[:display] = "block"
list_item["box-shadow"] = "-2em 1.5em 0 #e1e1e1"
lihover = Style("list-item:hover")
lihover[:background] = "#FFC0CB"
lihover[:color] = "#fffcfb"
lihover[:transform] = "translate(.9em, -.9em)"
lihover[:transition] = "all .25s linear"
lihover["box-shadow"] = "-2em 2em 0 #e1e1e1"
libefore = Style("list-item:after")

lfade = Animation("fade_left", length = 2.8)
lfade[:from] = "opacity" => "0%"
lfade[:to] = "opacity" => "100%"
lfade[:from] = "transform" => "translateX(100%)"
lfade[:to] = "transform" => "translateX(0%)"

heading1_style = Style("h1.fofh")
heading1_style["color"] = "pink"

heading2_style = Style("h2.fofht")
heading2_style["color"] = "lightblue"

logo_style = Style("img")
logo_style[:width] = "250"
animate!(logo_style, lfade)

coolscroll = Animation("scrolling", length = 25.5, iterations = 0)
coolscroll[0] = "transform" => "translateX(0%)"
coolscroll[50] = "transform" => "translateX(100%)"
coolscroll[100] = "transform" => "translateX(0%)"

hwscr = Style("h2.scroller")

animate!(hwscr, coolscroll)

hwscr[:color] = "lightblue"

graytxt = Style("grayness")
graytxt[:color] = "gray"
