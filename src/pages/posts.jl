mutable struct Post <: Servable
    ID::String
    readcount::Int64
    stars::Int64
    title::String
    sub::String
    img::String
    tags::Vector{String}
    uri::String
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
        new(ID, metainfo["readcount"], metainfo["stars"], metainfo["title"],
        metainfo["sub"], imgdata, Vector{String}(split(metainfo["tags"], ",")), uri)
    end
end

posts_main = div("posts-main", align = "left")
style!(posts_main, "padding" => 50px, "overflow-x" => "show", "overflow-y" => "scroll", "height" => 100percent)

function build_post_preview(post::Post)
    postname = replace(post.title, " " => "_", "'" => "")
    childs = [h3(text = post.title),
    h4(text = post.sub)]
    if post.img != ""
        insert!(childs, 1, img("-", src = post.img, width = 300))
    end
    on(EmsComputer.SESSION, "click$postname") do cm::ComponentModifier
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
        post_main = tmd("postmain", rawpost[maximum(data_end) + 1:end])
        closebutton = button("closeb", text = "close", align = "center")
        on(closebutton, "click") do cl::ClientModifier
            remove!(cl, "postbody")
        end
        style!(closebutton, "background-color" => "#911048", "color" => "white", "width" => 94percent, 
            "margin-bottom" => 100px)
        post_body = div("postbody", children = Vector{AbstractComponent}([closebutton]))
        style!(post_body, "width" => 94percent, "height" => 100percent, "z-index" => 15, "padding" => 3percent, 
        "background-color" => "#513154", "position" => "absolute", "left" => 0px, "top" => 0px)
        if length(childs) == 3
            push!(post_body, childs[2:3] ..., childs[1])
        else
            push!(post_body, childs ...)
        end
        push!(post_body, post_main)
        append!(cm, "mainbody", post_body)
    end
    sect = section("$postname", children = childs, class = "postbody")
    on("click$postname", sect, "click")
    sect
end

function build_collection_preview(dir_path::String)
    
end

function load_posts()
    posts = readdir("public/content/posts")
    sort!(
        posts;
        by = mtime,
        rev = true
    )
    for post_dir in reverse(posts)
        psh::Post = Post("public/content/posts/" * post_dir)
        push!(posts_main, build_post_preview(psh))
    end
end

function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:posts})
    menu = make_base_windowmenu(c, app, posts_main)
    style!(menu, "overflow-x" => "visible", "overflow-y" => "scroll")
    menu
end