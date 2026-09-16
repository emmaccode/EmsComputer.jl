mutable struct Post <: Servable
    ID::String
    readcount::Int64
    stars::Int64
    title::String
    sub::String
    img::String
    tags::Vector{String}
    uri::String
    series::String
    series_n::Int64
    function Post(uri::String)
        p = read(uri, String)
        metas = findfirst("```meta", p)
        imgs = findfirst("```img", p)
        metar = maximum(metas) + 1:findnext("```", p, metas[2])[1] - 1
        imgdata::String = if isnothing(imgs)
            ""
        else
            imgr = maximum(imgs) + 1:findnext("```", p, imgs[2])[1] - 1
            replace(p[imgr], "\n" => "")
        end
        metainfo = TOML.parse(p[metar])
        ID = ToolipsSession.gen_ref(16)
        (series, series_n) = if haskey(metainfo, "series")
            (metainfo["series"], metainfo["series_n"])
        else
            ("", 0)
        end
        new(ID, metainfo["readcount"], metainfo["stars"], metainfo["title"],
            metainfo["sub"], imgdata, Vector{String}(split(metainfo["tags"], ",")), uri, 
            series, series_n)::Post
    end
end

posts_main = div("posts-main", align = "left")
style!(posts_main, "padding" => 50px, "overflow-x" => "show", "overflow-y" => "scroll", "height" => 100percent)

more_posts_blog_link = section("bloglnk", class = "postbody", children = [
    h2(text = "Looking for more posts?"),
    h4(text = "click here to visit the blog!")
], onclick = "'window.location.href = \"/blog\"'")
push!(posts_main, more_posts_blog_link)

function build_post_preview(post::Post)
    childs = build_post_header_inner(post)
    sect = section(gen_ref(), children = childs, class = "postbody")
    sect
end

function create_popup(post::Post)
    post_main = build_post_full(post)
    closebutton = button("closeb", text = "close", align = "center")
    on(closebutton, "click") do cl::ClientModifier
        remove!(cl, "postbody")
    end
    style!(closebutton, "background-color" => "#911048", "color" => "white", "width" => 94percent, 
        "margin-bottom" => 100px)
    post_body = div("postbody", children = Vector{AbstractComponent}([closebutton]))
    style!(post_body, "width" => 94percent, "height" => 100percent, "z-index" => 15, "padding" => 3percent, 
    "background-color" => "#513154", "position" => "absolute", "left" => 0px, "top" => 0px)
    push!(post_body, post_main)
    post_body::AbstractComponent
end

function attach_popup_action!(c::AbstractConnection, post::Post, comp::AbstractComponent)
    on(c, comp, "click") do cm::ComponentModifier
        post_body = create_popup(post)
        append!(cm, "mainbody", post_body)
    end
    nothing::Nothing
end

function attach_popup_action!(post::Post, comp::AbstractComponent)
    ref = ToolipsSession.gen_ref()
    on(SESSION, ref) do cm::ComponentModifier
        popup = create_popup(post)
        append!(cm, "mainbody", popup)
    end
    on(ref, comp, "click")
    nothing::Nothing
end

function attach_redirect_action!(c::AbstractConnection, post::Post, comp::AbstractComponent)
    postfname = split(post.uri, "/")[end]
    postfname = replace(postfname, ".md" => "", " " => "_", ":" => "%", "_" => "||")
    comp[:onclick] = "'window.location.href = \"/blog/post?postname=$postfname\";'"
    nothing::Nothing
end

function get_raw_post(post::Post)
    rawpost = read(post.uri, String)
    found_img = findfirst("```img", rawpost)
    data_end = if ~(isnothing(found_img))
        findnext("```", rawpost, maximum(found_img))
    else
        findnext("```", rawpost, 3)
    end
    if isnothing(data_end)
        @warn "Error with post $(post.title) -- could not find end to meta-info."
        return
    end
    rawpost[maximum(data_end) + 1:end]::String
end

function build_post_body(post::Post)
    post_main = tmd("postmain", get_raw_post(post))
    post_main::Component{:div}
end

function build_post_header_inner(post::Post)
    postname = replace(post.title, " " => "_", "'" => "")
    childs = Vector{AbstractComponent}()
    if post.series != ""
        push!(childs, h4(text = string(post.series_n), align = "right"),
        h5(text = post.series, align = "right"))
    end
    if post.img != ""
        push!(childs, img("-", src = post.img, width = 300))
    end
    push!(childs, h3(text = post.title),
        h4(text = post.sub))
    childs
end

function build_post_header(post::Post)
    childs = build_post_header_inner(post)
    sect = div("$(gen_ref)-header", children = childs)
    sect
end

function build_post_full(post::Post)
    header = build_post_header(post)
    bod = build_post_body(post)
    sect = div(gen_ref(), children = [header, bod])
end

function get_collection_posts(series_name::String)
    collection_items = Vector{Post}()
    posts_dir = "public/content/posts/"
    for post_n in readdir(posts_dir)
        pst = Post(posts_dir * post_n)
        if series_name == pst.series
            push!(collection_items, pst)
        end
    end
    collection_items::Vector{Post}
end

function build_collection_preview(series_name::String)
    items = get_collection_posts(series_name)

end

function load_posts_by_recent(sort::Bool = true)
    posts = readdir("public/content/posts")
    if sort
        sort!(
        posts;
        by = p -> stat(joinpath("public/content/posts", p)).mtime,
        rev = true
        )
    end
    posts
end

function load_posts()
    posts = load_posts_by_recent()
    n = length(posts)
    nposts = if n < 5
        length(posts)
    else
        5
    end
    for post_dir in reverse(posts)[1:nposts]
        psh::Post = Post("public/content/posts/" * post_dir)
        preview = build_post_preview(psh)
        attach_popup_action!(psh, preview)
        push!(posts_main, preview)
    end
end

function build_post_previews(c::AbstractConnection, range::UnitRange{Int64} = 1:5)
    posts = load_posts_by_recent()
    if length(posts) < maximum(range)
        range = 1:length(posts)
    end
    slice = @views posts[range]
    [begin
        post = Post("public/content/posts/" * post_dir)
        preview = build_post_preview(post)
        attach_redirect_action!(c, post, preview)
        preview
    end for post_dir in slice]
end

function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:posts})
    menu = make_base_windowmenu(c, app, posts_main)
    menu[:align] = "left"
    style!(menu, "overflow-x" => "visible", "overflow-y" => "scroll")
    menu
end