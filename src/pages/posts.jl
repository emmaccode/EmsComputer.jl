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

function attach_redirect_action!(post::Post, comp::AbstractComponent)
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

function interpolate_julia(s::String)
    set_text!(JL_highlighter, s)
    OliveHighlighters.mark_julia!(JL_highlighter)
    contents = string(JL_highlighter)
    outer = div("-", text = contents)
    style!(outer, "padding" => 2percent, "background-color" => "#050203", "border-radius" => 3pt)
    string(outer)
end

function interpolate_img(s::String)
    width = ""
    if contains(s, ";")
        w_splits = split(s, ";")
        s = w_splits[2]
        width = w_splits[1]
    end
    image = img("-", src = s)
    if width != ""
        image[:width] = width
    end
    string(image)
end

function mark_python!(tm::OliveHighlighters.TextStyleModifier)
    OliveHighlighters.mark_between!(tm, "\"\"\"", :multistring)
    OliveHighlighters.mark_between!(tm, "'", :string)
    OliveHighlighters.mark_between!(tm, "\"", :string)
    OliveHighlighters.mark_line_after!(tm, "#", :comment)
    OliveHighlighters.mark_all!(tm, "return", :from)
    OliveHighlighters.mark_before!(tm, "(", :funcn, until = [" ", "\n", ",", ".", "\"", "&nbsp;",
    "<br>", "("])
    OliveHighlighters.mark_all!(tm, "def", :func)
    OliveHighlighters.mark_all!(tm, "float", :datatype)
    OliveHighlighters.mark_all!(tm, "str", :datatype)
    OliveHighlighters.mark_all!(tm, "int", :datatype)
    OliveHighlighters.mark_all!(tm, "bool", :datatype)
    [OliveHighlighters.mark_all!(tm, string(dig), :number) for dig in digits(1234567890)]
    OliveHighlighters.mark_all!(tm, "True", :number)
    OliveHighlighters.mark_all!(tm, "import", :import)
    OliveHighlighters.mark_all!(tm, ":", :number)
    OliveHighlighters.mark_all!(tm, "False", :number)
    OliveHighlighters.mark_all!(tm, "elif", :if)
    OliveHighlighters.mark_all!(tm, "pass", :keyword)
    OliveHighlighters.mark_all!(tm, "as", :keyword)
    OliveHighlighters.mark_all!(tm, "if", :if)
    OliveHighlighters.mark_all!(tm, "else", :if)
    OliveHighlighters.mark_all!(tm, "del", :none)
    OliveHighlighters.mark_all!(tm, "None", :none)
    OliveHighlighters.mark_all!(tm, "in", :keyword)
    OliveHighlighters.mark_all!(tm, "for", :from)
    OliveHighlighters.mark_all!(tm, "from", :from)
    OliveHighlighters.mark_all!(tm, "class", :class)
    OliveHighlighters.mark_all!(tm, "self", :self)
end

function highlight_python!(tm::OliveHighlighters.TextStyleModifier)
    style!(tm, :multistring, ["color" => "#122902"])
    style!(tm, :string, ["color" => "#3c5e25"])
    style!(tm, :func, ["color" => "#fc038c"])
    style!(tm, :funcn, ["color" => "#8b0000"])
    style!(tm, :if, ["color" => "#fc038c"])
    style!(tm, :number, ["color" => "#8b0000"])
    style!(tm, :import, ["color" => "#fc038c"])
    style!(tm, :keyword, ["color" => "#fc038c"])
    style!(tm, :default, ["color" => "#e0e0e0"])
    style!(tm, :self, ["color" => "#990833"])
    style!(tm, :from, ["color" => "#220899"])
    style!(tm, :datatype, ["color" => "#147e8c"])
    style!(tm, :none, ["color" => "#9e6400"])
    style!(tm, :class, ["color" => "#3a107d"])
end

PYTHON_highlighter = OliveHighlighters.Highlighter()
highlight_python!(PYTHON_highlighter)

function interpolate_py(s::String)
    set_text!(PYTHON_highlighter, s)
    mark_python!(PYTHON_highlighter)
    contents = string(PYTHON_highlighter)
    outer = div("-", text = contents)
    style!(outer, "padding" => 2percent, "background-color" => "#050203", "border-radius" => 3pt)
    string(outer)
end

function mark_C!(tm::OliveHighlighters.TextStyleModifier)

    tm.raw = replace(tm.raw, "<br>" => "\n", "</br>" => "\n", "&nbsp;" => " ")

    # comments
    OliveHighlighters.mark_between!(tm, "/*", "*/", :comment)
    OliveHighlighters.mark_line_after!(tm, "//", :comment)

    # strings + characters
    OliveHighlighters.mark_between!(tm, "\"", :string)
    OliveHighlighters.mark_between!(tm, "'", :char)

    # preprocessor directives
    OliveHighlighters.mark_line_after!(tm, "#include", :include)
    OliveHighlighters.mark_after!(tm, "#include", :included,
        until = ["\n", "<", ">", "\"", "&nbsp;", "<br>"])

    # functions
    OliveHighlighters.mark_before!(tm, "(", :funcn,
        until = [" ", "\n", ",", ".", "\"", "&nbsp;", "<br>", "(", ")", ";"])

    # types
    for typ in [
        "void", "char", "short", "int", "long", "float", "double",
        "signed", "unsigned", "size_t", "ptrdiff_t",
        "int8_t", "int16_t", "int32_t", "int64_t",
        "uint8_t", "uint16_t", "uint32_t", "uint64_t"
    ]
        OliveHighlighters.mark_all!(tm, typ, :type)
    end

    # structs
    for keyword in ["struct", "union", "enum", "typedef"]
        OliveHighlighters.mark_all!(tm, keyword, :struct)
    end

    # keywords
    for keyword in [
        "auto", "break", "case", "const", "continue", "default", "do",
        "else", "extern", "for", "goto", "if", "register", "restrict",
        "return", "static", "switch", "volatile", "while", "inline",
        "_Alignas", "_Alignof", "_Atomic", "_Bool", "_Complex",
        "_Generic", "_Imaginary", "_Noreturn", "_Static_assert",
        "_Thread_local"
    ]
        OliveHighlighters.mark_all!(tm, keyword, :keyword)
    end

    # numbers
    for dig in digits(1234567890)
        OliveHighlighters.mark_all!(
            tm,
            Char('0' + dig),
            :number,
            is_number_only = true
        )
    end

    OliveHighlighters.mark_all!(tm, "NULL", :number)
    OliveHighlighters.mark_all!(tm, "true", :number)
    OliveHighlighters.mark_all!(tm, "false", :number)

    nothing::Nothing
end

function interpolate_C(s::String)
    set_text!(C_highlighter, s)
    mark_C!(C_highlighter)
    contents = string(C_highlighter)
    outer = div("-", text = contents)
    style!(
        outer,
        "padding" => 2percent,
        "background-color" => "#050203",
        "border-radius" => 3pt
    )
    string(outer)
end

function highlight_C!(tm::OliveHighlighters.TextStyleModifier)
    style!(tm, :type, ["color" => "#576a8c"])
    style!(tm, :struct, ["color" => "#576a8c"])
    style!(tm, :keyword, ["color" => "#576a8c"])
    style!(tm, :default, ["color" => "#e0e0e0"])
    style!(tm, :include, ["color" => "#21cc2c"])
    style!(tm, :included, ["color" => "#8c28de"])
    style!(tm, :func, ["color" => "#28d2de"])
    style!(tm, :funcn, ["color" => "#28d2de"])
    style!(tm, :comment, ["color" => "#808080"])
    style!(tm, :multistring, ["color" => "#122902"])
    style!(tm, :string, ["color" => "#3c5e25"])
    style!(tm, :char, ["color" => "#8b0000"])
    style!(tm, :number, ["color" => "#8b0000"])
    nothing::Nothing
end

C_highlighter = Highlighter()

highlight_C!(C_highlighter)

function mark_html!(tm::OliveHighlighters.TextStyleModifier)
    # HTML comments
    OliveHighlighters.mark_between!(tm, "<!--", "-->", :comment)
    OliveHighlighters.mark_between!(tm, "<style", "</style>", :styleblock)
    OliveHighlighters.mark_inside!(tm, :styleblock) do tm2::OliveHighlighters.TextStyleModifier
        mark_CSS!(tm2)
        nothing::Nothing
    end
    OliveHighlighters.mark_between!(tm, "<script", "</script>", :scrblock)
    OliveHighlighters.mark_inside!(tm, :scrblock) do tm2::OliveHighlighters.TextStyleModifier
        mark_JS!(tm2)
        nothing::Nothing
    end
    OliveHighlighters.mark_between!(tm, "<", ">", :tag)
    OliveHighlighters.mark_inside!(tm, :tag) do tm2::OliveHighlighters.TextStyleModifier
        OliveHighlighters.mark_all!(tm2, "<", :bracket)
        OliveHighlighters.mark_all!(tm2, ">", :bracket)
        # Closing /
        OliveHighlighters.mark_all!(tm2, "/", :close)
        # Tag name
        OliveHighlighters.mark_after!(
            tm2,
            "<",
            :tagname,
            until = [" ", "\n", "/", ">", "\t"]
        )
        for attr in [
            "id", "class", "style", "src", "href", "alt",
            "title", "width", "height", "name", "value",
            "type", "rel", "charset", "lang", "target",
            "placeholder", "action", "method", "for",
            "onclick", "onload", "disabled", "checked",
            "selected", "required", "readonly"
        ]
            OliveHighlighters.mark_all!(tm2, attr, :attribute)
        end
        OliveHighlighters.mark_all!(tm2, "=", :equals)
        # Attribute values
        OliveHighlighters.mark_between!(tm2, "\"", :value)
        OliveHighlighters.mark_between!(tm2, "'", :value)
        nothing::Nothing
    end
    OliveHighlighters.mark_between!(tm, "&", ";", :entity)
    nothing::Nothing
end

function highlight_html!(
    tm::OliveHighlighters.TextStyleModifier;
    exclude_default::Bool = false
)

    if ~(exclude_default)
        style!(tm, :default, ["color" => "#e0e0e0"])
    end

    style!(tm, :tag,       ["color" => "#fc038c"])
    style!(tm, :tagname,   ["color" => "#28d2de"])
    style!(tm, :bracket,   ["color" => "#fc038c"])
    style!(tm, :close,     ["color" => "#fc038c"])
    style!(tm, :attribute, ["color" => "#8b0000"])
    style!(tm, :equals,    ["color" => "#e0e0e0"])
    style!(tm, :value,     ["color" => "#3c5e25"])
    style!(tm, :entity,    ["color" => "#8c28de"])
    style!(tm, :comment,   ["color" => "#808080"])
    style!(tm, :css,       ["color" => "#e0e0e0"])
    highlight_CSS!(tm)
    highlight_JS!(tm)
    nothing::Nothing
end


function mark_CSS!(tm::OliveHighlighters.TextStyleModifier)
    OliveHighlighters.mark_between!(tm, "/*", "*/", :comment)
    OliveHighlighters.mark_between!(tm, "\"", :string)
    OliveHighlighters.mark_between!(tm, "'", :string)
    OliveHighlighters.mark_before!(
        tm,
        "{",
        :selector,
        until = ["}", ";", "\n"]
    )
    for property in [
        "color", "background", "background-color",
        "font", "font-size", "font-family", "font-weight",
        "width", "height", "min-width", "max-width",
        "min-height", "max-height",
        "margin", "margin-top", "margin-right",
        "margin-bottom", "margin-left",
        "padding", "padding-top", "padding-right",
        "padding-bottom", "padding-left",
        "border", "border-radius",
        "display", "position",
        "top", "right", "bottom", "left",
        "align", "align-items", "justify-content",
        "flex", "flex-direction", "flex-wrap",
        "grid", "grid-template-columns",
        "opacity", "overflow", "visibility",
        "content", "transform",
        "transition", "animation",
        "text-align", "text-decoration",
        "line-height", "letter-spacing",
        "cursor", "z-index"
    ]
        OliveHighlighters.mark_all!(tm, property, :property)
    end
    OliveHighlighters.mark_after!(
        tm,
        "@",
        :at,
        until = [" ", "\n", "{", ";"]
    )
    OliveHighlighters.mark_after!(tm, "#", :hex,
        until = ["\n", "<", ">", "\"", "&nbsp;", "<br>"])
    for dig in digits(1234567890)
        OliveHighlighters.mark_all!(
            tm,
            Char('0' + dig),
            :number,
            is_number_only = true
        )
    end
    for unit in [
        "px", "em", "rem", "%", "vh", "vw",
        "vmin", "vmax", "s", "ms", "deg"
    ]
        OliveHighlighters.mark_all!(tm, unit, :unit)
    end
    OliveHighlighters.mark_all!(tm, "!important", :important)
    OliveHighlighters.mark_all!(tm, "--", :variable)
    nothing::Nothing
end


function highlight_CSS!(tm::OliveHighlighters.TextStyleModifier;
        exclude_default::Bool = false)
    if ~(exclude_default)
        style!(tm, :default, ["color" => "#e0e0e0"])
    end
    style!(tm, :selector,  ["color" => "#c73c32"])
    style!(tm, :property,  ["color" => "#554196"])
    style!(tm, :string,    ["color" => "#419660"])
    style!(tm, :number,    ["color" => "#8b0000"])
    style!(tm, :unit,      ["color" => "#8c28de"])
    style!(tm, :comment,   ["color" => "#808080"])
    style!(tm, :at,        ["color" => "#43B3AE"])
    style!(tm, :important, ["color" => "#ff0066"])
    style!(tm, :variable,  ["color" => "#D67229"])
    style!(tm, :hex, ["color" => "#76a15d"])
    nothing::Nothing
end

function mark_JS!(tm::OliveHighlighters.TextStyleModifier)
    OliveHighlighters.mark_line_after!(tm, "//", :comment)
    OliveHighlighters.mark_between!(tm, "/*", "*/", :comment)
    OliveHighlighters.mark_between!(tm, "\"", :string)
    OliveHighlighters.mark_between!(tm, "'", :string)
    OliveHighlighters.mark_between!(tm, "`", :template)
    # template interpolation
    OliveHighlighters.mark_inside!(tm, :template) do tm2::OliveHighlighters.TextStyleModifier
        OliveHighlighters.mark_between!(tm2, "\${", "}", :interp)
        OliveHighlighters.mark_inside!(tm2, :interp) do tm3::OliveHighlighters.TextStyleModifier
            mark_javascript!(tm3)
            nothing::Nothing
        end
        nothing::Nothing
    end
    OliveHighlighters.mark_before!(
        tm,
        "(",
        :funcn,
        until = [" ", "\n", ",", ".", "\"", "'", "`", "&nbsp;", "<br>", "("]
    )

    # keywords
    for keyword in [
        "break", "case", "catch", "class", "const",
        "continue", "debugger", "default", "delete",
        "do", "else", "export", "extends", "finally",
        "for", "from", "function", "if", "import",
        "in", "instanceof", "let", "new", "of",
        "return", "super", "switch", "this", "throw",
        "try", "typeof", "var", "void", "while",
        "with", "yield", "async", "await", "static",
        "get", "set"
    ]
        OliveHighlighters.mark_all!(tm, keyword, :keyword)
    end
    for value in [
        "true", "false", "null", "undefined", "NaN", "Infinity"
    ]
        OliveHighlighters.mark_all!(tm, value, :constant)
    end

    # built-ins
    for builtin in [
        "Array", "Boolean", "Date", "Error", "Function",
        "JSON", "Map", "Math", "Number", "Object",
        "Promise", "RegExp", "Set", "String", "Symbol",
        "WeakMap", "WeakSet", "console", "window",
        "document", "globalThis"
    ]
        OliveHighlighters.mark_all!(tm, builtin, :builtin)
    end
    for method in [
        "log", "map", "filter", "reduce", "forEach",
        "push", "pop", "shift", "unshift", "slice",
        "splice", "join", "split", "replace", "match",
        "test", "toString", "valueOf", "length"
    ]
        OliveHighlighters.mark_all!(tm, method, :method)
    end
    for dig in digits(1234567890)
        OliveHighlighters.mark_all!(
            tm,
            Char('0' + dig),
            :number,
            is_number_only = true
        )
    end
    OliveHighlighters.mark_between!(tm, "/", "/", :regex)
    for op in [
        "===", "!==", "==", "!=", ">=", "<=",
        "=>", "++", "--", "&&", "||", "??",
        "+=", "-=", "*=", "/=", "%=",
        "**", "?.", "...",
        "+", "-", "*", "/", "%", "=",
        ">", "<", "!", "&", "|", "^", "~",
        "?", ":"
    ]
        OliveHighlighters.mark_all!(tm, op, :op)
    end
    nothing::Nothing
end

function highlight_JS!(tm::OliveHighlighters.TextStyleModifier;
        exclude_default::Bool = false)
    if ~(exclude_default)
        style!(tm, :default, ["color" => "#e0e0e0"])
    end
    style!(tm, :keyword,  ["color" => "#fc038c"])
    style!(tm, :string,   ["color" => "#3c5e25"])
    style!(tm, :template, ["color" => "#3c5e25"])
    style!(tm, :interp,   ["color" => "#420000"])
    style!(tm, :comment,  ["color" => "#808080"])
    style!(tm, :funcn,    ["color" => "#28d2de"])
    style!(tm, :constant, ["color" => "#9e6400"])
    style!(tm, :builtin,  ["color" => "#147e8c"])
    style!(tm, :method,   ["color" => "#8b0000"])
    style!(tm, :number,   ["color" => "#8b0000"])
    style!(tm, :regex,    ["color" => "#8c28de"])
    style!(tm, :op,       ["color" => "#0C023E"])
    nothing::Nothing
end


HTML_highlighter = OliveHighlighters.Highlighter()
highlight_html!(HTML_highlighter)

CSS_highlighter = OliveHighlighters.Highlighter()
highlight_CSS!(CSS_highlighter)

JS_highlighter = OliveHighlighters.Highlighter()
highlight_JS!(JS_highlighter)

function interpolate_javascript(s::String)

    set_text!(JS_highlighter, s)

    mark_JS!(JS_highlighter)

    contents = string(JS_highlighter)

    outer = div("-", text = contents)

    style!(
        outer,
        "padding" => 2percent,
        "background-color" => "#050203",
        "border-radius" => 3pt
    )

    string(outer)
end

function interpolate_CSS(s::String)
    set_text!(CSS_highlighter, s)
    mark_CSS!(CSS_highlighter)
    contents = string(CSS_highlighter)
    outer = div("-", text = contents)
    style!(
        outer,
        "padding" => 2percent,
        "background-color" => "#050203",
        "border-radius" => 3pt
    )
    string(outer)
end

function escape_html(s::String)
    return replace(s,
        "&" => "&amp;",
        "<" => "&lt;",
        ">" => "&gt;",
        "\"" => "&quot;",
        "'" => "&#39;"
    )
end

function escape_with_marks(tm::OliveHighlighters.TextStyleModifier)

    raw = tm.raw

    escaped = IOBuffer()

    # offset[i] = number of extra characters introduced
    # before original character i
    offsets = zeros(Int, length(raw) + 1)

    offset = 0
    i = 0

    for c in raw

        i += 1

        escaped_c = escape_html(string(c))

        write(escaped, escaped_c)

        offset += length(escaped_c) - 1
        offsets[i + 1] = offset

    end

    tm.raw = String(take!(escaped))

    # Rebuild marks using their new positions.
    old_marks = collect(tm.marks)
    empty!(tm.marks)

    for (r, mark) in old_marks

        start = minimum(r)
        stop = maximum(r)

        new_start = start + offsets[start]
        new_stop = stop + offsets[stop + 1]

        tm.marks[new_start:new_stop] = mark

    end

    tm

end

function interpolate_html(s::String)
    set_text!(HTML_highlighter, s)
    mark_html!(HTML_highlighter)
    escape_with_marks(HTML_highlighter)
    contents = string(HTML_highlighter)
    outer = div("-", text = contents)
    style!(
        outer,
        "padding" => 2percent,
        "background-color" => "#050203",
        "border-radius" => 3pt
    )
    string(outer)
end

function showhtml_interpolate(s::String)
    string(div("-", text = Toolips.Components.rep_in(s)))
end

function build_post_body(post::Post)
    rawpost = replace(get_raw_post(post), "+" => "|[PLUS]|", "<" => "|[ARRL]|", 
        ">" => "|[ARRR]|", "\"" => "|[QUOT]|")
    post_main = tmd("postmain", rawpost)
    post_main[:text] = replace(post_main[:text], "|[PLUS]|" => "+", "|[ARRL]|" => "<", "|[ARRR]|" => ">", 
        "|[QUOT]|" => "\"", "&#39;" => "\"", "&#37;" => "%")
    interpolate!(post_main, "julia" => interpolate_julia, "img" => interpolate_img, "python" => interpolate_py, 
        "c" => interpolate_C, "html" => interpolate_html, "js" => interpolate_javascript, "css" => interpolate_CSS, 
        "showhtml" => showhtml_interpolate)
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

function load_posts_by_category(categories::Vector{String})
    posts = load_posts_by_recent(false)
    posts_in_category::Vector{Post} = Vector{Post}()
    if length(categories) == 0
        return(posts_in_category)
    end
    stub = "public/content/posts/"
    for posturi in posts
        post = Post(stub * posturi)
        if all(tag -> tag in post.tags, categories)
            push!(posts_in_category, post)
        end
    end
    posts_in_category
end

function load_posts_by_recent(sort::Bool = true, range::UnitRange{Int64} = -15:-15)
    posts = readdir("public/content/posts")

    if sort
        sort!(
        posts;
        by = p -> stat(joinpath("public/content/posts", p)).mtime,
        rev = true
        )
    end
    if range != -15:-15
        n = length(posts)
        if maximum(range) > n
            start = minimum(range)
            if start > n
                return(nothing)
            end
            range = start:n
        end
        posts = posts[range]
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

function build_post_previews(posts::Vector{String})
    [begin
        post = Post("public/content/posts/" * post_dir)
        preview = build_post_preview(post)
        attach_redirect_action!(post, preview)
        preview
    end for post_dir in posts]
end

function build_post_previews(posts::Vector{Post})
    [begin
        preview = build_post_preview(post)
        attach_redirect_action!(post, preview)
        preview
    end for post in posts]
end


function build_post_previews(c::AbstractConnection, range::UnitRange{Int64} = 1:5)
    posts = load_posts_by_recent(true, range)
    if isnothing(posts)
        return(Vector{AbstractComponent}())
    end
    build_post_previews(posts)::Vector{<:AbstractComponent}
end

function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:posts})
    menu = make_base_windowmenu(c, app, posts_main)
    menu[:align] = "left"
    style!(menu, "overflow-x" => "visible", "overflow-y" => "scroll")
    menu
end