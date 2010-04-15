require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "haml"
require "sass"
require "curb"
require "nokogiri"
require "lib/flickr"
require 'maruku'

# Default is xhtml, do not want!
set :haml, {:format => :html5 }

# Contants
@root = "http://localhost:4567"

get '/' do
  
  # Render the HAML template
  haml :index
  
end

#get '/photos/:who/:page' do
get %r{/photos/([a-zA-Z0-9\+]+)(/([0-9]+))?} do

  # Setup some variables we'll use in the template
  @username = params[:captures][0]
  if params[:captures][2] == nil
    @page = 1
  else
    @page = Integer(params[:captures][2])
  end
  @page_next = @page + 1
  @page_prev = @page - 1
  
  # Create a new Flickr object and get the user ID
  flickr = Flickr.new
  user_id = flickr.get_user_id(@username)
  
  # Check for errors
  if (user_id = "User not found")
  
    # ERROR! User was not found
    haml :error
  
  else
    
    # All is good, continue on our way
    # Get the photos
    @photos = flickr.get_photos(user_id, @page, 10)
  
    # Get the number of pages
    @pages = flickr.pages
  
    # Get user info
    @user = flickr.get_user_info(user_id)
  
    # Render the HAML template
    haml :photos
    
  end
  
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