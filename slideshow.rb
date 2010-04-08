require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "haml"
require "sass"
require "curb"
require "nokogiri"
require "lib/flickr"

# Default is xhtml, do not want!
set :haml, {:format => :html5 }

# Contants
@root = "http://localhost:4567"

get '/' do
  "hello world"
end

get '/photos/:who' do
  
  # Setup some variables we'll use in the template
  @username = params[:who]
  @page = 1
  @page_next = @page + 1
  @page_prev = @page - 1
  
  # Create a new Flickr object and get the user ID
  flickr = Flickr.new
  user_id = flickr.get_user_id(@username)
  
  # Get the photos
  @photos = flickr.get_photos(user_id, @page)
  
  # Render the HAML template
  haml :index
  
end

get '/photos/:who/:page' do
  
  # Setup some variables we'll use in the template
  @username = params[:who]
  @page = Integer(params[:page])
  @page_next = @page + 1
  @page_prev = @page - 1
  
  # Create a new Flickr object and get the user ID
  flickr = Flickr.new
  user_id = flickr.get_user_id(@username)
  
  # Get the photos
  @photos = flickr.get_photos(user_id, @page)
  
  # Get the number of pages
  @pages = flickr.pages
  
  # Get user info
  @user = flickr.get_user_info(user_id)
  
  # Render the HAML template
  haml :index
  
end

# Stylesheets
get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/reset.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :reset
end