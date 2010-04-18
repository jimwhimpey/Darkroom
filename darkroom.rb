require "rubygems"
require "sinatra"
require "haml"
require "sass"
require "curb"
require "nokogiri"
require "lib/flickr"
require 'maruku'

configure :development do
  require "sinatra/reloader"
end

# Default is xhtml, do not want!
set :haml, {:format => :html5 }

get '/' do
  # Render the HAML template
  haml :index
end

# ==========================================
# Sets Page

get %r{/photos/([\[\]\(\)\{\}\.\|\_\-\*\+\sa-zA-Z0-9]+)/sets/?$} do
  
  # Grab the username
  @username = params[:captures][0].gsub /\s/, '+'
  
  # Create a new Flickr object and get the user ID
  flickr = Flickr.new
  user_id = flickr.get_user_id(@username)
  
  # Get user info
  @user = flickr.get_user_info(user_id)
  
  # Check for errors
  if (user_id == "User not found")
    # ERROR! User was not found
    haml :error
  else
    # All is good, grab the sets
    @sets = flickr.get_sets(user_id)
    # Render the HAML template
    haml :sets
  end
  
end

# ==========================================
# Photostream and Sets Photostream

get %r{/photos/([\[\]\(\)\{\}\.\|\_\-\*\+\sa-zA-Z0-9]+)(/([0-9]+))?(/sets/([0-9]+))?(/([0-9]+))?} do

  # Check if we're showing a photostream or a set
  if params[:captures][4] != nil
    # We're getting a set
    set = params[:captures][4]
  else
    # Standard photostream
    set = false
  end

  # Grab the username
  @username = params[:captures][0].gsub /\s/, '+'
  
  # Set the page variables
  if params[:captures][2] == nil && params[:captures][6] == nil
    @page = 1
  else
    if set != false
      @page = Integer(params[:captures][6])
    else
      @page = Integer(params[:captures][2])
    end
  end
  @page_next = @page + 1
  @page_prev = @page - 1
  
  # Create a new Flickr object and get the user ID
  flickr = Flickr.new
  user_id = flickr.get_user_id(@username)
  
  # Check for errors
  if (user_id == "User not found")
  
    # ERROR! User was not found
    haml :error
  
  else
    
    # All is good, continue on our way
    # Get the photos
    @photos = flickr.get_photos(user_id, @page, 10, set)
  
    # Get the number of pages
    @pages = flickr.pages
    
    # Set the set name and set var if there is one
    if set != false
      @set = true
      @set_id = params[:captures][4]
      @set_name = flickr.set_name
    end
  
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