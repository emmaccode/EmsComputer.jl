function text_styles()
    heading1_style = Style("h1.fofh")
    heading1_style["color"] = "pink"
    heading2_style = Style("h2.fofht")
    heading2_style["color"] = "lightblue"
    graytxt = Style("grayness")
    graytxt[:color] = "gray"
    components(heading1_style, heading2_style, graytxt)
end

function anim_lfade()
    lfade = Animation("fade_left", length = 2.8)
    lfade[:from] = "opacity" => "0%"
    lfade[:to] = "opacity" => "100%"
    lfade[:from] = "transform" => "translateX(100%)"
    lfade[:to] = "transform" => "translateX(0%)"
    lfade
end

function logo_sty()
    logo_style = Style("img.logo")
    logo_style[:width] = "250"
    lfade = anim_lfade()
    animate!(logo_style, anim_lfade())
    logo_style
end

function anim_coolscroll()
    coolscroll = Animation("scrolling", length = 10.0, iterations = 0)
    coolscroll[0] = "transform" => "translateX(45%)"
    coolscroll[50] = "transform" => "translateX(50%)"
    coolscroll[100] = "transform" => "translateX(45%)"
    coolscroll
end

function scrolly_style()
    hwscr = Style("h2.scroller")
    animate!(hwscr, anim_coolscroll())
    hwscr[:color] = "lightblue"
    return(hwscr)
end

function button_style()
    style = Style("button", padding = "20px")
    style["background-color"] = "pink"
    style["font-size"] = "15pt"
    style["color"] = "white"
    style
end

function stylesheet()
    components(anim_coolscroll(), logo_sty(), scrolly_style(), button_style())
end
