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
        imgr = maximum(imgs) + 1:findnext("```", p, imgs[2])[1] - 1
        imgdata = replace(p[imgr], "\n" => "")
        metainfo = TOML.parse(p[metar])
        ID = ToolipsSession.gen_ref(16)
        new(ID, metainfo["readcount"], metainfo["stars"], metainfo["title"],
        metainfo["sub"], imgdata, Vector{String}(split(metainfo["tags"], ",")), uri)
    end
end

posts_main = div("posts-main", align = "left")
style!(posts_main, "padding" => 50px, "overflow-x" => "show", "overflow-y" => "scroll")
for post_dir in readdir("public/content/posts")
    psh::Post = Post("public/content/posts/" * post_dir)
    postbody = section("postbody")
    push!(postbody, img("$(psh.title)-i", src = psh.img, width = 300),
    h3("$(psh.title)-t", text = psh.title),
    h4("$(psh.title)-st", text = psh.sub))
    push!(posts_main, postbody)
end

function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:posts})
    bar = div("posts-menu", align = "right", expanded = 1, children = [posts_main])
    on(c, bar, "click") do cm::ComponentModifier
        if cm["posts-menu"]["expanded"] == "0"
            style!(cm, "posts-menu", "width" => 100percent)

        end
    end
    style!(bar, "background-color" => app.color, "height" => 100percent, 
    "width" => 0percent, "transition" => 1500ms, "display" => "inline-block", "display" => "none", 
    "overflow" => "hidden")
    bar
end