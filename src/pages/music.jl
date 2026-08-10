function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:music})
    menu = make_base_windowmenu(c, app, MUSIC_MAIN)
    style!(menu, "overflow-x" => "hidden", "overflow-y" => "scroll")
    return(menu)
end

function build_musicplayer_track(track_name::String, music_dir::String)
    safe_trackname = replace(track_name, ".ogg" => "", ".mp3" => "", ".wav" => "")
    label = h3(text = safe_trackname, style = "color:#1e1e1e;")
    safe_trackname  = replace(safe_trackname, " " => "_", ":" => "")
    track_href = music_dir * "/$track_name"
    listen_button = button("listn", text = "listen to this track")
    on("click$safe_trackname", listen_button, "click")
    on(SESSION, "click$safe_trackname") do cm::ComponentModifier
        if "popup" in cm
            return
        end
        player = Component{Symbol("audio controls")}("plyr", src = track_href)
        close_button = div("closeb", text = "close")
        style!(close_button, "background-color" => "darkred", "padding" => 2percent, "color" => "white")
        on(close_button, "click") do cl::ClientModifier
            remove!(cl, "popup")
        end
        player_div = div("popup", children = [close_button, player], align = "center")
        style!(player_div, "padding" => 2percent, "left" => 0percent, "top" => 0percent, "width" => 96percent, "height" => 100percent, 
            "background-color" => "rgba(30, 30, 30, .9)", "z-index" => 60, "position" => "absolute")
        append!(cm, "mainbody", player_div)
    end
    dl_button = button("download", text = "download audio", 
        onclick = "'window.location.href = \"$track_href\";'")
    player_wrapper = div("plywrp", children = [listen_button, dl_button])
    overbox = div("overbox", children = [label, player_wrapper])
    style!(overbox, "padding" => 1.5percent, "border" => "1px solid #1e1e1e", 
        "border-radius" => 3pt, "background-color" => "#E75480")
    overbox::Component{:div}
end

function build_musicplayer_album(album_name::String, music_dir::String)
    safename = replace(album_name, " " => "")
    on(SESSION, "click$safename") do cm::ComponentModifier
        if "alpopup" in cm || "popup" in cm
            return
        end
        close_button = div("closebal", text = "close")
        style!(close_button, "background-color" => "darkred", "padding" => 2percent, "color" => "white")
        on(close_button, "click") do cl::ClientModifier
            remove!(cl, "alpopup")
        end
        album_path = "content/music" * "/$album_name"
        tracks = [build_musicplayer_track(uri, album_path) for uri in readdir("public/" * album_path)]
        insert!(tracks, 1, close_button)
        player_div = div("alpopup", children = tracks, align = "center")
        style!(player_div, "padding" => 2percent, "left" => 0percent, "top" => 0percent, "width" => 96percent, "height" => 100percent, 
            "background-color" => "rgba(30, 30, 30, .9)", "z-index" => 60, "position" => "absolute")
        append!(cm, "mainbody", player_div)
    end
    album_label = h1(text = "album", style = "color:#1e1e1e;opacity:75%")
    album_nlabel = h2(text = album_name)
    overbox = div("null", children = [album_label, album_nlabel])
    on("click$safename", overbox, "click")
    style!(overbox, "padding" => 1.5percent, "border" => "1px solid #1e1e1e", 
        "border-radius" => 3pt, "background-color" => "#E75480", "cursor" => "pointer")
    overbox
end

function make_music_player_page()
    music_dir = "public/content/music"
    div("musicmain", align = "left", children = [begin
        if isdir(music_dir * "/" * uri)
            build_musicplayer_album(uri, "content/music")
        else
            build_musicplayer_track(uri, "content/music")
        end
    end for uri in readdir(music_dir)])::Component{:div}
end

MUSIC_MAIN = make_music_player_page()