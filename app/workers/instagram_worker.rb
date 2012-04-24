require 'instagram'

class InstagramWorker
  @queue = :observers
  
  def initialize(instagram_account_id)
    @account = OauthAccount.find_by_id(instagram_account_id)
  end
  
  def manybots_client
    @manybots_client ||= Manybots::Client.new(@account.user.authentication_token)
  end
  
  def post_to_manybots!(media)
    self.manybots_client.create_activity media_as_activity(media)
  end
  
  def load_instagram_client
    Instagram.configure do |config|
      config.client_id = ManybotsInstagram.instagram_app_id
      config.client_secret = ManybotsInstagram.instagram_app_secret
    end
    Instagram.client(:access_token => @account.token)
  end
  
  def client
    @client ||= load_instagram_client
  end
  
  def min_id
    @account.payload[:min_id]
  end
  
  def max_id
    @account.payload[:max_id]
  end
  
  def max_id=(id)
    @account.payload[:max_id] = id
    @account.save and @account.reload
    id
  end
  
  def min_id=(id)
    @account.payload[:min_id] = id
    @account.save and @account.reload
    id
  end
  
  def get_recent_media(options={})
    params = {count: 60}
    results = self.client.user_recent_media params.merge(options)
    @next_max_id = (results.count == 60 ? results.last.id : 0)
    results
  end
  
  def get_all_media
    @next_max_id = 0
    params = {min_id: self.min_id}
    results = self.get_recent_media params
    results.delete_at(-1) if results.last.id == self.min_id 
    unless results.empty?
      self.min_id= results.first.id 
      while @next_max_id != 0
        results += self.get_recent_media params.merge(max_id: @next_max_id)
      end
    end
    results
  end
  
  def self.perform(instagram_account_id)
    worker = self.new(instagram_account_id)
    recent_media = worker.get_all_media
    recent_media.each do |media|
      worker.post_to_manybots!(media)
    end
  end
  
private

  def media_as_activity(media)
    activity = {
      published: Time.at(media.created_time.to_i).xmlschema,
      verb: media.link.present? ? 'post' : 'save',
      title: "ACTOR #{media.link.present? ? 'posted' : 'saved'} OBJECT#{' at TARGET' if media.location.present? and media.location.name.present?}",
      content: "<p><img src='#{media.images.thumbnail.url}' /></p>",
      auto_title: true,
      tags: media.tags.push(media.filter), 
      icon: {
        url: ManybotsInstagram.app.app_icon_url
      }
    }
    activity[:object] = {
      objectType: 'photo',
      displayName: media.caption.present? ? media.caption.text : 'Unnamed photo',
      id: "tag:instagr.am,#{Time.now.year}:media/#{media.id}",
      url: media.link || media.images.standard_resolution.url,
      image: {
        width: media.images.standard_resolution.width,
        height: media.images.standard_resolution.height,
        url: media.images.standard_resolution.url
      }
    }
    if media.location.present?
      activity[:target] = {
        objectType: 'place',
        displayName: media.location.name || "Unnamed location",
        position: "#{media.location.latitude} #{media.location.longitude}",
        id: "tag:instagr.am,#{Time.now.year}:locations/#{media.location.id}",
        url: "#{ManybotsInstagram.app.url}/locations/#{media.location.id}"
      }
    end
    activity[:provider] = ManybotsInstagram.app.as_provider
    activity[:generator] = {
      url: 'http://instagr.am',
      displayName: 'Instagram',
      image: {
        url: ManybotsInstagram.app.app_icon_url
      }
    }
    activity
  end
  
end