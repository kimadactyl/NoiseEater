require "favicon_maker"
FaviconMaker.generate do

  setup do
    template_dir  "./public/images/favicon"
    output_dir    "./public/"
  end

  from "favicon_hires.png" do
    icon "apple-touch-icon-152x152-precomposed.png"
    icon "apple-touch-icon-144x144-precomposed.png"
    icon "apple-touch-icon-120x120-precomposed.png"
    icon "apple-touch-icon-114x114-precomposed.png"
    icon "favicon-196x196.png"
    icon "favicon-160x160.png"
    icon "favicon-96x96.png"
    icon "mstile-144x144", format: "png"
    icon "apple-touch-icon-76x76-precomposed.png"
    icon "apple-touch-icon-72x72-precomposed.png"
    icon "apple-touch-icon-60x60-precomposed.png"
    icon "apple-touch-icon-57x57-precomposed.png"
    icon "apple-touch-icon-precomposed.png", size: "57x57"
    icon "apple-touch-icon.png", size: "57x57"
    icon "favicon-32x32.png"
  end

  from "favicon.png" do
    icon "favicon-16x16.png"
    icon "favicon.png", size: "16x16"
    icon "favicon.ico", size: "64x64,32x32,24x24,16x16"
  end

  each_icon do |filepath|
    puts filepath # verbose example
  end
end