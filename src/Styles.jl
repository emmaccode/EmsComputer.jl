function text_styles()
    heading1_style = Style("h1")
    heading1_style["color"] = "white"
    heading2_style = Style("h2")
    heading2_style["color"] = "gray"
    graytxt = Style("p")
    graytxt[:color] = "gray"
    [heading1_style, heading2_style, graytxt]
end

function anim_logoin()
    lfade = keyframes("lfadein")
    keyframes!(lfade, :from, "opacity" => 0percent, "transform" => translateX(100percent))
    keyframes!(lfade, :to, "opacity" => 100percent, "transform" => translateX(0percent))
    lfade
end

function move_mainup()
    animat = keyframes("maingoup")
    keyframes!(animat, :from, "transform" => translatyY(0percent))
    keyframes!(animat, :to, "transform" => translateY(-120percent))
    animat
end



function anim_logoout()
    lfade = keyframes("lfadeout")
    keyframes!(lfade, :from, "opacity" => 100percent, "transform" => translateX(0percent))
    keyframes!(lfade, :to, "opacity" => 0percent, "transform" => translateX(-100percent))
    lfade
end

function logo_sty()
    logo_style = Style("img.logo")
    logo_style[:width] = "250"
    style!(logo_style, "animation-name" => "lfadein", "animation-duration" => 800ms)
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
    vcat([logo_sty(), button_style(), anim_logoin(), anim_logoout(),
    move_mainup()],
    text_styles())
end
