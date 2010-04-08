class Flickr
  
  @@pages = 1
  
  def pages
    @@pages
  end
  
  # Method for getting a Flickr user ID from a username
  def get_user_id username
    
    # Get Flickr user ID by username and then make the call to Flickr
    username_call = Curl::Easy.perform(username_url  = "http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=8242e922f3c5029f480fe8552f42b457&username=#{username}")
    
    # Grab the "real" user id from Flickr, I don't know why a normal username isn't considered an ID
    doc = Nokogiri::XML(username_call.body_str)
    user_id = doc.css('rsp user')[0]['id']
    
    # Return the ID
    return user_id
    
  end
  
  # Method for getting a user's Flickr photos, getting the image URL and some info
  # Returns it all in a nice array full of hashes
  def get_photos user_id, page
    
    # Create the Flickr URL and make the call for this user's list of photos
    photos_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=8242e922f3c5029f480fe8552f42b457&user_id=#{user_id}&per_page=2&page=#{page}")
  
    # Grab their photos feed
    doc = Nokogiri::XML(photos_call.body_str)
    photos_xml = doc.css('rsp photos photo')
  
    # Find the number of pages and set the instance var
    @@pages = doc.css('rsp photos')[0]['pages']
  
    # Create an array for holding all the photos information
    photos = Array.new
  
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
        
      # Grab the large image's info
      large_url = large[0]['source']
      large_width = large[0]['width']
      large_height = large[0]['height']
    
      # Get the title, description, comment count and URL of the photo
      title = info_doc.css('photo title')[0].content
      description = info_doc.css('photo description')[0].content
      url = info_doc.css('photo urls url[type=photopage]')[0].content
      comments = info_doc.css('photo comments')[0].content
    
      # Create hash of this photo's data
      photo = Hash[ "large_url" => large_url,
                    "title" => title,
                    "description" => description,
                    "url" => url,
                    "comments" => comments,
                    "width" => large_width,
                    "height" => large_height]
    
      # Add that hash to the photos array
      photos << photo
    
    end
    
    # Return the data
    return photos
    
  end
  
  ## Get info about a user
  def get_user_info(user_id)
    
    # Create the Flickr URL and make the call for this user's info
    user_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=8242e922f3c5029f480fe8552f42b457&user_id=#{user_id}")
    
    # Grab their photos feed
    doc = Nokogiri::XML(user_call.body_str)
    user_xml = doc.css('person')
    
    # Grab the info we want
    user_nsid = user_xml[0]['nsid']
    user_iconserver = user_xml[0]['iconserver']
    user_iconfarm = user_xml[0]['iconfarm']
    user_name = user_xml.css("username")[0].content
    
    # Construct the avatar URL
    avatar = "http://farm#{user_iconfarm}.static.flickr.com/#{user_iconserver}/buddyicons/#{user_nsid}.jpg"
    
    # Add it to a user hash
    user = Hash[  "avatar" => avatar,
                  "name" => user_name]
    
    # Return the user's info
    return user
    
  end
  
end