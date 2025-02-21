function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:posts})
    bar = div("posts-menu", align = "right", expanded = 1)
    on(c, bar, "click") do cm::ComponentModifier
        if cm["colorpages-menu"]["expanded"] == "0"
            style!(cm, "colorpages-menu", "width" => 100percent, "padding" => 20px)
            set_children!(cm, "colorpages-menu", 
            Vector{AbstractComponent}([close_app_button, (make_app_preview(c, app) for app in APPS) ...]))
            cm["colorpages-menu"] = "expanded" => "1"
        end
    end
    style!(bar, "background-color" => app.color, "height" => 85percent, 
    "width" => 0percent, "transition" => 700ms, "display" => "inline-block", "display" => "none")
    bar
end