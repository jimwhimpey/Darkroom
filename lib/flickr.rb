class Flickr
  
  @@pages = 1
  
  def pages
    @@pages
  end
  
  # Method for getting a Flickr user ID from a username
  def get_user_id username
    
    # Get Flickr user ID by username and then make the call to Flickr
    username_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=8242e922f3c5029f480fe8552f42b457&username=#{username}")
    
    # Grab the "real" user id from Flickr, I don't know why a normal username isn't considered an ID
    doc = Nokogiri::XML(username_call.body_str)

    # Check to see if the user was found
    stat = doc.css('rsp')[0]['stat']
    if stat == "fail"
      user_id = "User not found"
    else
      user_id = doc.css('rsp user')[0]['id']
    end
    
    # Return the ID
    return user_id
    
  end
  
  # Method for getting a user's Flickr photos, getting the image URL and some info
  # Returns it all in a nice array full of hashes
  def get_photos user_id, page, per_page
    
    # Create the Flickr URL and make the call for this user's list of photos
    photos_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=8242e922f3c5029f480fe8552f42b457&user_id=#{user_id}&per_page=#{per_page}&page=#{page}")
  
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
      
      # If the image is wider than 1024 (which can happen when the uploaded picture is 
      # bigger than 1024 but not big enough to have an original version AND a large version)
      # we want to artificially resize it down to 1024 wide and also correctly scale the height
      if (Float(large_width) > 1024)
        ratio = ((1024/Float(large_width))*1000).round / 1000.0
        new_height = Float(large_height) * ratio
        large_width = 1024
        large_height = new_height.ceil
      end
    
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
  
  # Method for getting a list of Flickr user's sets
  def get_sets user_id
    
    # Create an array for holding all the set's information
    sets = Array.new
    
    # Make call to the Flickr API
    sets_call = Curl::Easy.perform("http://api.flickr.com/services/rest/?method=flickr.photosets.getList&api_key=8242e922f3c5029f480fe8552f42b457&user_id=#{user_id}")
    
    # Parse the response
    doc = Nokogiri::XML(sets_call.body_str)
    
    # Get the array of sets
    sets_xml = doc.css('rsp photosets')[0].css('photoset')
    
    # Loop through the results 
    sets_xml.each do |set_xml|
    
      # Create hash of this set's data
      set = Hash[ "id" => set_xml['id'], "title" => set_xml.css('title')[0].content]

      # Add that hash to the photos array
      sets << set
    
    end
    
    # Return the sets
    return sets
    
  end
  
end