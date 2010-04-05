class Flickr
  
  def initialize
    puts "testing"
  end
  
  def self.testing_test
    puts "test"
  end
  
  # Method for getting a Flickr user ID from a username
  def get_user_id username
    
    # Get Flickr user ID by username and then make the call to Flickr
    username_call = Curl::Easy.perform(username_url  = "http://api.flickr.com/services/rest/?method=flickr.people.findByUsername&api_key=8242e922f3c5029f480fe8552f42b457&username=#{username}")
    
    # Grab the "real" user id from Flickr, I don't know why a normal username isn't considered an ID
    doc = Nokogiri::XML(username_call.body_str)
    user_id = doc.css('rsp user')[0]['id']
    
    return user_id
    
  end
  
end