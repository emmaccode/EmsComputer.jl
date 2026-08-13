function make_windowmenu(c::AbstractConnection, app::ColorPagesApp{:notebooks})
    build_nbdirectory_container(c, "notebooks")
end

function build_nbdirectory_container(c::AbstractConnection, uri::String)
    directory_box = div("directories", children = make_nb_directories(uri))
end

function make_nb_directories(uri::String)
    current_uri = "public/$uri/"
    for filename in readdir(current_uri)
        if isfile(current_uri * filename)
            make_nbitem_file(current_uri, filename)
        else
            make_nbitem_folder(current_uri, filename)
        end
    end
end

function make_nbitem_file(current_uri::AbstractString, filename::AbstractString)
    label = a(text = filename)
    style!(label, "padding" => .5percent)
    open_button = a(text = "open")
    download_button = a(text = "download")
    common = ("padding" => .5percent, "color" => "white", "border-radius" => 3pt)
    style!(download_button, "background-color" => "#1e1e1e", common ...)
    style!(open_button, "background-color" => "#449e71", common ...)
    box = div("nbitem", children = [label, open_button, download_button])
end

function make_nbitem_folder(current_uri::AbstractString, filename::AbstractString)
    label = a(text = filename)
    style!(label, "padding" => .5percent)
    open_button = a(text = "open")
    download_button = a(text = "download")
    common = ("padding" => .5percent, "color" => "white", "border-radius" => 3pt)
    style!(download_button, "background-color" => "#1e1e1e", common ...)
    style!(open_button, "background-color" => "#449e71", common ...)
    box = div("nbitem", children = [label, open_button, download_button])
end

function read_notebook_into_components(notebook_uri::String)
    cells = if contains(notebook_uri, ".ipynb")
        IPyCells.read_ipynb(notebook_uri)
    elseif contains(notebook_uri, ".jl")
        IPyCells.read_jl(notebook_uri)
    else
        Vector{IPyCells.Cell}
    end
    [begin 
        make_cell_preview(cell)
    end for cell in cells]
end

function make_base_preview(cell::Cell{<:Any})
    
end

function make_cell_preview(cell::Cell{<:Any})

end

function make_cell_preview(cell::Cell{:markdown})

end

function make_cell_preview(cell::Cell{:code})

end