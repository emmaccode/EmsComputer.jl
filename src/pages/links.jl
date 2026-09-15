function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:links})
    main = div("-", align = "center", children = [h2(text = "link page")])
    style!(main, "padding-top" => 20percent)
    menu = make_base_windowmenu(c, app, main)
end
