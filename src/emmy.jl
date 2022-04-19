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
    head = header()
    navbar = make_navbar()
    page_css= main_css()
    welcome = html("<h1>Hello!</h1></div>")
    feed = blogfeeder()
    greeting = greeter()
    cols = Columns("home_cols", 2, [feed], [greeting])
    Page([page_css, head, navbar, welcome, cols], "emmy's site")
end
function greeter()
    html("""<h3>Who is Emmy Boudreau</h3>
    <p>My name is Emmett Boudreau, I am a Data Scientist, Software Developer,
    and Scientific journalist currently residing in Tennessee. Feel free to check
    out my projects
    """)
end
function blogfeeder()
    html("""
    <!-- start sw-rss-feed code -->
    <script type="text/javascript">
    <!--
    rssfeed_url = new Array();
    rssfeed_url[0]="https://rss.app/feeds/frhz6TaU8MpeU2QZ.xml";
    rssfeed_frame_width="500";
    rssfeed_frame_height="1000";
    rssfeed_scroll="on";
    rssfeed_scroll_step="6";
    rssfeed_scroll_bar="off";
    rssfeed_target="_blank";
    rssfeed_font_size="15";
    rssfeed_font_face="";
    rssfeed_border="on";
    rssfeed_css_url="https://feed.surfing-waves.com/css/style4.css";
    rssfeed_title="on";
    rssfeed_title_name="";
    rssfeed_title_bgcolor="#3366ff";
    rssfeed_title_color="#fff";
    rssfeed_title_bgimage="";
    rssfeed_footer="off";
    rssfeed_footer_name="rss feed";
    rssfeed_footer_bgcolor="#fff";
    rssfeed_footer_color="#333";
    rssfeed_footer_bgimage="";
    rssfeed_item_title_length="50";
    rssfeed_item_title_color="#666";
    rssfeed_item_bgcolor="#fff";
    rssfeed_item_bgimage="";
    rssfeed_item_border_bottom="on";
    rssfeed_item_source_icon="off";
    rssfeed_item_date="off";
    rssfeed_item_description="on";
    rssfeed_item_description_length="120";
    rssfeed_item_description_color="#666";
    rssfeed_item_description_link_color="#333";
    rssfeed_item_description_tag="on";
    rssfeed_no_items="0";
    rssfeed_cache = "5708345e73ab2b7b14f8c396d3f6ae20";
    //-->
    </script>
    <script type="text/javascript" src="//feed.surfing-waves.com/js/rss-feed.js"></script>
    <!-- The link below helps keep this service FREE, and helps other people find the SW widget. Please be cool and keep it! Thanks. -->
    <div style="color:#ccc;font-size:10px; text-align:right; width:500px;">powered by <a href="https://surfing-waves.com" rel="noopener" target="_blank" style="color:#ccc;">Surfing Waves</a></div>
    <!-- end sw-rss-feed code -->""")
end

function main_css()
    css("""ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background-color: #CD5E77;
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
}
h1 {
  display: block;
  font-size: 2em;
  font-family: "Lucida Console", "Courier New", monospace;
  margin-top: 0.67em;
  margin-bottom: 0.67em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
  color: #3A3B3C;
}
""")
end
main()
