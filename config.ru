require "haml"
require 'sass/plugin/rack'
Sass::Plugin.options[:template_location] = "views"
Sass::Plugin.options[:css_location] = "public"
use Sass::Plugin::Rack

require "darkroom"
run Sinatra::Application