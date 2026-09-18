back_to_em = button(gen_ref(), text = "<- back to em's computer", align = "center")
on(back_to_em, "click") do cl::ClientModifier
    redirect!(cl, "/")
end


pixie_home = route("/pixie") do c::AbstractConnection
    write!(c, "<!DOCTYPE html>")
    write!(c, create_styles())
    scrub_logo = img(src = "media/logos/pixie.png", width = 200px)
    scrub_label = h2(text = "pixie")
    scrub_header = div("-", align = "center", children = [scrub_logo, scrub_label])
    scrub_descript = p(text = """pixie is a node-based image editor and animation tool I am currently working on. 
        Development is ongoing, but off and on as I work to finish my other projects. Once I get a few more projects out 
        of the way, this project will become a focus for some time.""", align = "left")
    scrub_body = div("-", children = [
            scrub_descript,
        ], align = "center")
    style!(scrub_header, "animation-name" => "fadeup", 
        "animation-duration" => 500ms)
    scrub_splash = div("-", children = [scrub_header, scrub_body])
    mainbod = body("mainbod", children = [scrub_splash, back_to_em])
    style!(mainbod, "background-color" => "#cb7da0", "padding" => 30percent)
    write!(c, mainbod)
end

scrub_home = route("/scrub") do c::AbstractConnection
    write!(c, "<!DOCTYPE html>")
    write!(c, create_styles())
    scrub_logo = img(src = "media/logos/scrub.png", width = 200px)
    scrub_label = h2(text = "SCRUB")
    scrub_header = div("-", align = "center", children = [scrub_logo, scrub_label])
    scrub_reader = h4(text = "the scrub project is currently in early development, check back for updates.")
    style!(scrub_reader, "color" => "#050505")
    scrub_descript = p(text = "scrub is a work-in-progress, open-source video editor project based in the Godot engine.")
    scrub_body = div("-", children = [
            scrub_descript,
            scrub_reader
        ], align = "center")
    style!(scrub_header, "animation-name" => "fadeup", 
        "animation-duration" => 500ms)
    scrub_splash = div("-", children = [scrub_header, scrub_body, back_to_em])
    mainbod = body("mainbod", children = [scrub_splash])
    style!(mainbod, "background-color" => "#414086")
    write!(c, mainbod)
end

push!(EmsComputer.ROUTES, scrub_home, pixie_home)