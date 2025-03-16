MODELS_MAIN = begin
    model_previews = [begin
        folder_name = split(model_meta, "-")
        model_name = replace(folder_name[2], ".txt" => "")
        td_frame = iframe("-", src = "/modelview/index.html?folder=$(folder_name[1])&name=$model_name", width = 400, height = 500, scrolling = "no", 
        frameBorder = 0)
        common = ("font-size" => 13pt, "font-weight" => "bold", "padding" => 13px, "width" => 374px, "cursor" => "pointer")
        name_indicator = div("name-indicator", text = model_name, align = "center")
        style!(name_indicator, "background-color" => "white", common ...)
        download_glb = div("download_glb", text = "download glb", align = "center")
        style!(download_glb, "background-color" => "darkblue", "color" => "white", common ...)
        download_blender = div("download_blender", text = "download blender", align = "center")
        style!(download_blender, "background-color" => "#ad4d0c", "color" => "white", common ...)
        details_button = div("details", text = "details", align = "center")
        style!(details_button, "background-color" => "#1e1e1e", "color" => "white", common ...)
        on(download_glb, "click") do cl::ClientModifier
            redirect!(cl, "/media/models/$(folder_name[1])/$model_name.glb")
        end
        on(download_blender, "click") do cl::ClientModifier
            redirect!(cl, "/media/models/$(folder_name[1])/$model_name.blend")
        end
        on(SESSION, "details-$model_name") do cm::ComponentModifier
            if "popup" in cm
                remove!(cm, "popup")
                return
            end
            close_button = button("close", text = "close")
            on(close_button, "click") do cl::ClientModifier
                remove!(cl, "popup")
            end
            style!(close_button, "background-color" => "red", "padding" => 6px, "font-weight" => "bold")
            close_button_wrapper = div("-", align = "right", children = [close_button])
            model_title = h3(text = model_name)
            model_desc = tmd("-", read("public/media/models/meta" * "/$model_meta", String))
            new_dialog = div("popup", children = [close_button_wrapper, model_title, model_desc])
            style!(new_dialog, "background-color" => "white", "padding" => 10px, "border" => "3px solid #1e1e1e", "z-index" => 10, 
            "position" => "absolute", "width" => 20percent, "left" => 40percent, "top" => 30percent)
            append!(cm, "mainbody", new_dialog)
        end
        on("details-$model_name", details_button, "click")
        model_div = div("-", children = [name_indicator, td_frame, download_glb, download_blender, details_button])
        style!(model_div, "border" => "2px solid #1e1e1e", "border-radius" => 5px, "display" => "block")
        model_div
    end for model_meta in readdir("public/media/models/meta")]
    preview_box = div("modelmain", children = model_previews)
    style!(preview_box, "display" => "flex", "padding" => 2percent)
    preview_box
end


function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:models})
    bar = div("models-menu", align = "right", expanded = 1, children = [MODELS_MAIN])
    on(c, bar, "click") do cm::ComponentModifier
        if cm["models-menu"]["expanded"] == "0"
            style!(cm, "models-menu", "width" => 100percent, "padding" => 2percent)

        end
    end
    style!(bar, "background-color" => app.color, "height" => 100percent, 
    "width" => 0percent, "transition" => 1500ms, "display" => "inline-block", "display" => "none", 
    "overflow" => "hidden", "padding" => 0percent)
    bar
end