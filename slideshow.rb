require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "haml"
require "curb"
require "nokogiri"
require "lib/flickr"

# Default is xhtml, do not want!
set :haml, {:format => :html5 }

get '/' do
  "hello world"
end

get '/user/:who' do
  
  # Create a new Flickr object
  flickr = Flickr.new
  
  # Get the User ID
  user_id = flickr.get_user_id params[:who]
  
  # Get the photos
  @photos = flickr.get_photos user_id, 1
  
  # Render the HAML template
  haml :index
  
end

get '/user/:who/:page' do
  
  "With a page number"
  
end