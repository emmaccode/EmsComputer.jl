function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:games})
    main = div("-", align = "center", children = [h2(text = "no games available.... yet")])
    style!(main, "padding-top" => 20percent)
    menu = make_base_windowmenu(c, app, main)
end
