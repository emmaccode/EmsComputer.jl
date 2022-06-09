function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end


hello_world = route("/") do c
    write!(c, p("hello", text = "hello world!"))
end
fourofour = route("404", p("404", text = "404, not found!"))
rs = routes(hello_world, fourofour)
main(rs)

        