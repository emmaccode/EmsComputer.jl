function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:music})
    menu = make_base_windowmenu(c, app, MUSIC_MAIN)
    style!(menu, "overflow-x" => "hidden", "overflow-y" => "scroll")
    return(menu)
end