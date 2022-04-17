# Welcome to your new Toolips server!
using Toolips

function main()
        # Essentials
    global LOGGER = Logger()
    tst = ServerTemplate(IP, PORT, logger = LOGGER)
    home = home_page()
    tst.add(Route("/", home))
    global TLSERVER = tst.start()
end

function make_navbar()
    navbar_lists = lists("Home" => "/", "Projects" => "/projects",
    "Content" => "/content", "About" => "/about")
    UnorderedList("navbar", navbar_lists)
end

function header()
    image = """<a href="https://ibb.co/vzvM47b"><img src="https://i.ibb.co/YjTVBz6/default.png" alt="default" border="0" width = "300" height = "300"></a>"""
    divopen = "<div align = 'center'>"
    html(divopen * image)
end

function home_page()
    navbarcss = css("""ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background-color: #333;
}

li {
  float: left;
}

li a {
  display: block;
  color: white;
  text-align: center;
  padding: 14px 16px;
  text-decoration: none;
}

li a:hover {
  background-color: #111;
}""")
    head = header()
    navbar = make_navbar()
    greeting = html("<h1>Hello!</h1>")
    open_container = """</div>
    <div class="float-container">"""
    Page([navbarcss, head, navbar, greeting], "emmy's site")
end
main()
