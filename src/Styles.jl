function text_styles()
    heading1_style = Style("h1")
    heading1_style["color"] = "white"
    heading2_style = Style("h2")
    heading2_style["color"] = "gray"
    graytxt = Style("p")
    graytxt[:color] = "gray"
    components(heading1_style, heading2_style, graytxt)
end

function anim_logoin()
    lfade = Animation("lfadein", length = 2.8)
    lfade[:from] = "opacity" => "0%"
    lfade[:to] = "opacity" => "100%"
    lfade[:from] = "transform" => "translateX(100%)"
    lfade[:to] = "transform" => "translateX(0%)"
    lfade
end

function anim_logoout()
    lfade = Animation("lfadeout", length = 2.8)
    lfade[:to] = "opacity" => "0%"
    lfade[:from] = "opacity" => "100%"
    lfade[:to] = "transform" => "translateX(-100%)"
    lfade[:from] = "transform" => "translateX(0%)"
    lfade
end

function logo_sty()
    logo_style = Style("img.logo")
    logo_style[:width] = "250"
    animate!(logo_style, anim_logoin())
    logo_style
end

function button_style()
    style = Style("button", padding = "20px")
    style["background-color"] = "pink"
    style["font-size"] = "15pt"
    style["color"] = "white"
    style
end

function stylesheet()
    vcat(components(logo_sty(), button_style(), anim_logoin(), anim_logoout()),
    text_styles())
end
