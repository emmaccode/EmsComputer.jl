JL_highlighter = OliveHighlighters.Highlighter()

OliveHighlighters.style_julia!(JL_highlighter)

function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:notebooks})
    build_nbdirectory_container(c, "notebooks")
end

function build_nbdirectory_container(c::AbstractConnection, uri::String)
    directory_box = div("directories", children = make_nb_directories(c, uri), align = "center",
        style="padding:4%;overflow-y:scroll;")
end

function make_nb_directories(c::AbstractConnection, uri::String)
    current_uri = "public/content/$uri/"
    dirs = [begin
        if isfile(current_uri * filename)
            make_nbitem_file(c, current_uri, filename)
        else
            make_nbitem_folder(c, current_uri, filename)
        end
    end for filename in readdir(current_uri[begin:end - 1])]
    if uri != "notebooks"
        new_bar = div("returner", text = "...", align = "center")
        style!(new_bar, "padding" => 3percent, "background-color" => "darkred", "font-weight" => "bold", "color" => "white", 
            "cursor" => "pointer")
        insert!(dirs, 1, new_bar)
        on(c, new_bar, "click") do cm::ComponentModifier
            dirsplits = split(uri, "/")
            uri = join(dirsplits[1:end - 1], "/")
            set_children!(cm, "directories", make_nb_directories(c, uri))
        end
    end
    dirs
end

function make_nbitem_file(c::AbstractConnection, current_uri::AbstractString, filename::AbstractString)
    label = a(text = replace(filename, ".ipynb" => "", ".jl" => ""))
    style!(label, "padding" => 1percent, "background-color" => "white", "font-size" => 18pt, "font-weight" => "bold")
    open_button = button(text = "open")
    on(c, open_button, "click") do cm::ComponentModifier
        header = img("emseyes", src = LOGO_URI, width = 350)
        loading_header = h2(text = "LOADING")
        logobg = div("logobg", align = "center", children = [header, loading_header])
        set_children!(cm, "directories", [logobg])
        cm["emseyes"] = "src" => "/images/animated.gif"
        on(c, cm, 5) do cm::ComponentModifier
            nb_comps = read_notebook_into_components(current_uri * filename)
            set_children!(cm, "directories", nb_comps)
        end
    end
    download_button = button(text = "download")
    common = ("padding" => 1percent, "color" => "white", "border-radius" => 3pt, "font-size" => 18pt)
    style!(download_button, "background-color" => "#1e1e1e", common ...)
    style!(open_button, "background-color" => "#449e71", common ...)
    box = div("nbitem", children = [label, open_button, download_button], style = "width:100%;display:inline-flex")
end

function make_nbitem_folder(c::AbstractConnection, current_uri::AbstractString, filename::AbstractString)
    label = a(text = filename)
    ficon = img(src = "/images/page-icons/files.png", width = 50px, 
        style = "background-color:#1e1e1e;padding:1%")
    style!(label, "padding" => 1percent, "cursor" => "pointer", "color" => "white", "background-color" => "#1e1e1e", "font-size" => 18pt, "font-weight" => "bold", 
        "margin-left" => 8px)
    on(c, label, "click") do cm::ComponentModifier
        uri = replace(current_uri, "public/content/" => "")
        set_children!(cm, "directories", make_nb_directories(c, uri * filename))
    end
    box = div("nbitem", children = [ficon, label], style = "width:100%;background-color:#1e1e1e;display:inline-flex")
end

function read_notebook_into_components(notebook_uri::String)
    cells = if contains(notebook_uri, ".ipynb")
        IPyCells.read_ipynb(notebook_uri)
    elseif contains(notebook_uri, ".jl")
        IPyCells.read_jl(notebook_uri)
    else
        Vector{IPyCells.Cell}
    end
    Vector{AbstractComponent}([make_cell_preview(cell) for cell in cells])
end

function make_base_preview(cell::Cell{<:Any})
    cell_source = div("src", text = cell.source)
    style!(cell_source, "background-color" => "#f9e8ff", "padding" => 30px, "border-radius" => 5pt)
    outputs = div("-", text = string(cell.outputs))
    style!(outputs, "padding" => 1percent, "background-color" => "#201e21", "color" => "white")
    container = div("-", children = [cell_source, outputs], style = "background-color:#111012;")
end

function make_cell_preview(cell::Cell{<:Any})
    make_base_preview(cell)
end

function make_cell_preview(cell::Cell{:markdown})
    tmd("-", cell.source)
end

function make_cell_preview(cell::Cell{:code})
    preview = make_base_preview(cell)
    sourcebox = preview[:children]["src"]
    set_text!(JL_highlighter, cell.source)
    OliveHighlighters.mark_julia!(JL_highlighter)
    sourcebox[:text] = string(JL_highlighter)
    preview
end