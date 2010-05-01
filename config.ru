require "haml"
require 'sass/plugin/rack'
Sass::Plugin.options[:template_location] = "views"
Sass::Plugin.options[:css_location] = "public"
use Sass::Plugin::Rack

# Default is xhtml, do not want!
set :haml, {:format => :html5}

require "darkroom"
run Sinatra::Application