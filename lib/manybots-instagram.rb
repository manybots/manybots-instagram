require "manybots-instagram/engine"

module ManybotsInstagram
  # Instagram App Id for OAuth2
  mattr_accessor :instagram_app_id
  @@instagram_app_id = nil

  # Instagram App Secret for OAuth2
  mattr_accessor :instagram_app_secret
  @@instagram_app_secret = nil
  
  mattr_accessor :app
  @@app = nil
  
  mattr_accessor :nickname
  @@nickname = nil
  
  
  def self.setup
    yield self
  end
end
