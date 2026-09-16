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

BLOG_SERIES_NAMES::Vector{Pair{String, String}} = Vector{Pair{String, String}}()

function load_series()
    posts = load_posts_by_recent(false)
    curr = "public/content/posts/"
    for posturi in posts
        post = Post(curr * posturi)
        if post.series != "" && post.series_n == 1
            if ~(post.series in BLOG_SERIES_NAMES)
                img = post.img
                push!(BLOG_SERIES_NAMES, post.series => img)
            end
        end
    end
    nothing::Nothing
end

function load_post_series(series)
    posts = load_posts_by_recent(false)
    curr = "public/content/posts/"
    in_series = Vector{Post}()
    for posturi in posts
        post = Post(curr * posturi)
        if post.series == series
            push!(in_series, post)
        end
    end
    sort!(in_series, by = p -> p.series_n)
    in_series::Vector{Post}
end

function make_series_preview(series_name::Pair{String, String})
    series_label = h2(text = series_name[1])
    safename = replace(series_name[1], " " => "_", "'" => "|_")
    series_box = section(gen_ref(), children = Vector{Components.AbstractComponent}([series_label]), 
        onclick = "'window.location.href = \"/blog/series?name=$(safename)\";'")
    style!(series_box, "padding" => .5percent, "cursor" => "pointer", 
        "border" => "2px solid black", "background-color" => "#212222")
    if series_name[2] != ""
        push!(series_box, img(width = 100, src = series_name[2]))
    end
    series_box::Component{:section}
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
    
    series_placeholder = div("seriesbox", 
        children = [make_series_preview(sern) for sern in BLOG_SERIES_NAMES])
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
    selected_categories::Vector{String} = Vector{String}()
    buttons = [begin
        tag_button = button(gen_ref(), text = tag, class = "categoryb")
        on(c, tag_button, "click") do cm::ComponentModifier
            found = findfirst(x -> x == tag, selected_categories)
            if isnothing(found)
                push!(selected_categories, tag)
                style!(cm, tag_button, "background" => "#be60d1")
            else
                deleteat!(selected_categories, found)
                style!(cm, tag_button, "background" => "transparent")
            end
            # now update post list
        end
        tag_button
    end for tag in ALL_POST_TAGS]
    cats_main = div("catsmain", children = buttons)
    posts_box = div("catposts")
    wrapper = div("-", children = [cats_main, posts_box])
    style!(wrapper, "padding" => 3percent)
    bod = body("mainbody", children = [build_blog_bar(c, "catmen"), wrapper], style = "background-color:#1a1818;color:white;padding:0%;")
    write!(c, bod)
end

series_route = route("/blog/series") do c::AbstractConnection
    write!(c, blog_menubutton_class, create_styles())
    bod = body("mainbody", children = [build_blog_bar(c, "sermen")], style = "background-color:#1a1818;color:white;padding:0%;")
    args = get_args(c)
    if haskey(args, :name)
        selected_series = replace(args[:name], "_" => " ", "|_" => "'")
        posts = load_post_series(selected_series)
        push!(bod, div("-", children = [begin
            prev = build_post_preview(post)
            attach_redirect_action!(c, post, prev)
            prev
        end for post in posts]))
    else
        push!(bod, div("-", children = [make_series_preview(sern) for sern in BLOG_SERIES_NAMES]))
    end
    write!(c, bod)
end

ALL_POST_TAGS::Vector{String} = Vector{String}()

function register_all_post_tags()
    @info "registering post tags"
    baseuri = "public/content/posts/"
    for posturi in load_posts_by_recent(false)
        post = Post(baseuri * posturi)
        for tag in post.tags
            if ~(tag in ALL_POST_TAGS)
                push!(ALL_POST_TAGS, tag)
                @info tag
            end
        end
    end
    @info "register complete"
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