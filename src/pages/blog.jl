function build_blog_bar(c::AbstractConnection, men_selected::String = "")
    blog_lg = img(src = "/images/animated-dark.gif", width = 40px, style = "padding:.5%;cursor:pointer;user-select:none;", 
        onclick = "'window.location.href = \"/\";'")
    blog_shower = a(text = "em's journals")
    style!(blog_shower, "font-size" => 20pt, "font-weight" => "bold", "color" => "#5b33b0", 
        "padding" => .5percent, "margin-left" => 2percent, "user-select" => "none")
    menu_home = a("homemen", text = "home", class = "blogmenubutton", style = "margin-left:10px;", 
        onclick = "'window.location.href = \"/blog\";'")
    menu_latest = a("latestmen", text = "latest", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/latest\";'")
    menu_cats = a("catmen", text = "categories", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/categories\";'")
    menu_series = a("sermen", text = "series", class = "blogmenubutton", onclick = "'window.location.href = \"/blog/series\";'")
    searchbar = a("searchtxt", contenteditable = "true")
    ToolipsSession.bind(c, searchbar, "Enter", prevent_default = true) do cm::ComponentModifier
        redirect!(cm, "/blog/search?q=$(cm[searchbar][:text])")
    end
    common = ("padding" => .5percent, "background-color" => "#242424", "border-radius" => 2pt, 
        "font-size" => 15pt, "float" => "right")
    style!(searchbar, "background-color" => "#242424", "width" => 23percent, "overflow" => "visible",
        "white-space" => "nowrap", "border" => "2px solid #854a96", "border-right" => 0px, common ...)
    iconbutton = a("srch", text = "search")
    style!(iconbutton, "border" => "2px solid #854a96", "border-left" => 0px, common ...)
    container = div("bar", children = [blog_lg, blog_shower, menu_home, menu_latest, menu_cats, menu_series, 
        searchbar, iconbutton])
    if ~(men_selected == "")
        sel_menu = container[:children][men_selected]
        sel_menu[:onclick] = ""
        style!(sel_menu, "background-color" => "#5b33b0")
    end
    style!(container, "background-color" => "#0f0f0f", "width" => 99percent, 
        "position" => "sticky", "top" => 0percent, "padding" => .5percent, "display" => "inline-flex", 
        "border-bottom-left-radius" => 4pt, "border-bottom-right-radius" => 4pt)
    container::Component{:div}
end


function fisher_yates_shuffle(v)
    v2 = copy(v)
    for i in length(v2):-1:2
        j = rand(1:i)
        v2[i], v2[j] = v2[j], v2[i]
    end
    return v2
end

function build_random_post_previews(c::AbstractConnection, count::Int = 5)
    posts = load_posts_by_recent()
    if isempty(posts)
        return []
    end
    # pick random unique posts
    count = min(count, length(posts))
    slice = fisher_yates_shuffle(posts)[1:count]
    [begin
        post = Post("public/content/posts/" * post_dir)
        preview = build_post_preview(post)
        attach_redirect_action!(c, post, preview)
        preview
    end for post_dir in slice]
end


blog_menubutton_class = style("a.blogmenubutton", "border-left" => "4px solid #8833b0", "border-top-right-radius" => 6pt,
    "cursor" => "pointer", "padding" => .5percent, "color" => "#d4cfb0", "font-size" => 20pt, "padding-left" => 1.5percent, "padding-right" => 1.5percent, 
    "transition" => 400ms)
blog_menubutton_class:"hover":["background-color" => "#0a0a0a", "color" => "#854a96", "border-bottom" => "4px solid #854a96", "font-weight" => "bold"]


blog_route = route("/blog") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    random_previews = build_random_post_previews(c, 5)
    left_box = section("randombox", children = random_previews)
    style!(left_box,
        "width" => 50percent,
        "display" => "inline-block",
        "vertical-align" => "top",
        "padding" => 2percent
    )
    series_placeholder = div("seriesbox", text = "Series go here")
    style!(series_placeholder,
        "width" => 50percent,
        "display" => "inline-block",
        "vertical-align" => "top",
        "padding" => 2percent,
        "color" => "white",
        "background-color" => "#252525",
        "font-size" => 18pt,
        "font-weight" => "bold",
        "text-align" => "center"
    )
    split_panel = div("splitpanel", children = [left_box, series_placeholder])
    style!(split_panel,
        "display" => "flex",
        "flex-direction" => "row",
        "width" => 100percent,
        "background-color" => "#1e1e1e"
    )
    latest_previews = build_post_previews(c, 1:10)
    latest_sect = section("latestsect", children = latest_previews)
    style!(latest_sect, "padding" => 2percent)
    bod = body("mainbody",
        children = [
            build_blog_bar(c, "homemen"),
            split_panel,
            latest_sect
        ],
        style = "background-color:#1a1818;color:white;padding:0%;"
    )

    write!(c, bod)
end

post_route = route("/blog/post") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    args = get_args(c)
    if ~(haskey(args, :postname))
        write!(c, "no post selected (temp message)")
        return
    end
    requested_post = replace(args[:postname], "_" => " ", "%" => ":", "||" => "_") * ".md"
    selected_post = Post("public/content/posts/" * requested_post)
    mainbod = build_post_full(selected_post)
    style!(mainbod, "padding" => 5percent)
    bod = body("mainbody", children = [build_blog_bar(c), mainbod], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

latest_route = route("/blog/latest") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    previews = build_post_previews(c::AbstractConnection, 1:10)
    if length(previews) == 10
        load_more = div("loadm", text = "load more", align = "center")
        style!(load_more, "color" => "white", "background-color" => "#1e1e1e", 
        "font-weight" => "bold", "font-size" => 16pt)
        on(c, load_more, "click") do cm::ComponentModifier

        end
    end
    latest_sect = section("latestsect", children = previews)
    style!(latest_sect, "padding" => 2percent)
    bod = body("mainbody", children = [build_blog_bar(c, "latestmen"), latest_sect], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

cats_route = route("/blog/categories") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    bod = body("mainbody", children = [build_blog_bar(c, "catmen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

series_route = route("/blog/series") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    bod = body("mainbody", children = [build_blog_bar(c, "sermen")], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

function get_postsearch_results(query::String)
    results::Vector{Post} = Post[]
    direc = "public/content/posts"
    for post_dir in readdir(direc)
        uri = "$direc/" * post_dir
        if ~(isfile(uri))
            continue
        end
        psh::Post = Post(uri)
        any_contains = findfirst(x -> contains(x, query), (psh.title, psh.sub, psh.series))
        is_result = ~(isnothing(any_contains)) || query in psh.tags
        if is_result
            push!(results, psh)
        end
    end
    results::Vector{Post}
end

search_route = route("/blog/search") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    args = get_args(c)
    searchbody = if haskey(args, :q)
        childs = [begin 
            build_post_preview(post) 
        end for post in get_postsearch_results(args[:q])]
        if length(childs) < 1
            div("pagebody", children = [a(text = "no results for search: '$(args[:q])'")])
        else
            div("pagebody", children = childs)
        end
    else
        div("pagebody", children = [a(text = "no search provided")])
    end
    style!(searchbody, "padding" => 2percent)
    bod = body("mainbody", children = [build_blog_bar(c), searchbody], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end


push!(EmsComputer.ROUTES, blog_route, latest_route, cats_route, series_route, search_route, 
    post_route)