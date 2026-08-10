pixie_home = route("/pixie") do c::AbstractConnection
    write!(c, "hello!")
end

scrub_home = route("/scrub") do c::AbstractConnection
    write!(c, "hello world!")
end

push!(EmsComputer.ROUTES, scrub_home, pixie_home)