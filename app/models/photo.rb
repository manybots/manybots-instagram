module ManybotsInstagram
  class Photo
    
    def as_activity(media)
      activity = {
        published: Time.at(media.created_time).xmlschema,
        verb: 'post',
        title: "ACTOR posted OBJECT#{' at TARGET' if media.location.present?}",
        auto_title: true,
        tags: media.tags.push(self.filter), 
      }
      activity[:object] = {
        objectType: 'photo',
        displayName: media.caption,
        id: "tag:instagr.am,#{Time.now.year}:media/#{media.id}"
        url: media.link,
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
          url: "http://instagr.am/locations/#{media.location.id}"
        }
      end
      activity[:provider] = ManybotsInstagram.app.as_provider
      activity[:generator] = {
        url: 'http://instagr.am',
        displayName: 'Instagram'
        image: {
          url: ManybotsInstagram.app.app_icon_url
        }
      }
      activity
    end
    
  end
end
