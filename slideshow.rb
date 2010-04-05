require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "haml"
require "curb"
require "nokogiri"

# Default is xhtml, do not want!
set :haml, {:format => :html5 }

get '/' do
  "hello world"
end

get '/user/:who' do
  
  # Get Flickr user ID by username and then make the call to Flickr
  username_call = Curl::Easy.perform(username_url  = "http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=8242e922f3c5029f480fe8552f42b457&username=#{params[:who]}")
  
  # Grab the "real" user id from Flickr, I don't know why a normal username isn't considered an ID
  doc = Nokogiri::XML(username_call.body_str)
  user_id = doc.css('rsp user')[0]['id']
  
  # Create the Flickr URL and make the call for this user's list of photos
  photos_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=8242e922f3c5029f480fe8552f42b457&user_id=#{user_id}&per_page=10")
  
  # Grab their photos feed
  doc = Nokogiri::XML(photos_call.body_str)
  photos_xml = doc.css('rsp photos photo')
  
  # Create an array for holding all the photos information
  @photos = Array.new
  
  # Loop through each returned photo and make another 
  # API call to get the correct size
  photos_xml.each do |photo_xml|

    # Make the call for this individual photo's sizes and it's info
    sizes_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=8242e922f3c5029f480fe8552f42b457&photo_id=#{photo_xml['id']}")
    info_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=8242e922f3c5029f480fe8552f42b457&photo_id=#{photo_xml['id']}")
    
    # Parse the sizes and info XML
    sizes_doc = Nokogiri::XML(sizes_call.body_str)
    info_doc = Nokogiri::XML(info_call.body_str)
    
    # Find the XML element of the large photo
    large = sizes_doc.css('sizes size[label=Large]')
    # If a large photo isn't found then we'll use the original
    if large.length == 0 then large = sizes_doc.css('sizes size[label=Original]') end
    # Grab the large image's URL
    large_url = large[0]['source']
    
    # Get the title, description and URL of the photo
    title = info_doc.css('photo title')[0].content
    description = info_doc.css('photo description')[0].content
    url = info_doc.css('photo urls url[type=photopage]')[0].content
    
    # Create hash of this photo's data
    photo = Hash[ "large_url" => large_url,
                  "title" => title,
                  "description" => description,
                  "url" => url]
    
    # Add that hash to the photos array
    @photos << photo
    
  end
  
  # Render the HAML template
  haml :index
  
end

get '/user/:who/:page' do
  
  "With a page number"
  
end