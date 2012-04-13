module ManybotsInstagram
  class InstagramController < ApplicationController
    require 'instagram'
    
    before_filter :authenticate_user!
    
    def index
      @instagrams = current_user.oauth_accounts.where(:client_application_id => current_app.id)
      @schedules = load_schedules
    end
    
    def new
      configure_instagram
      redirect_to Instagram.authorize_url(:redirect_uri => instagram_callback_url)
    end
    
    def callback
      configure_instagram
      response = Instagram.get_access_token(params[:code], :redirect_uri => instagram_callback_url)
      token = response.access_token
      
      client = Instagram.client(:access_token => token)
      instagram_user = client.user
      
      instagram = current_user.oauth_accounts.find_or_create_by_client_application_id_and_remote_account_id(current_app.id, instagram_user.id)
      instagram.payload[:username] = instagram_user.username
      instagram.token = token
      instagram.save
      
      redirect_to root_path, :notice => "Instagram account '#{instagram_user.username}' registered."
    end
    
    def toggle
      instagram = current_user.oauth_accounts.find(params[:id])
      load_schedule(instagram)
      message = 'Please try again.'
      if @schedule
        ManybotsServer.queue.remove_schedule @schedule_name
        instagram.status = 'off'
        message = 'Stoped importing.'
      else 
        instagram.status = 'on'
        message = 'Started importing.'        
            
        ManybotsServer.queue.add_schedule @schedule_name, {
          :every => '2h',
          :class => "InstagramWorker",
          :queue => "observers",
          :args => instagram.id,
          :description => "Import pictures from Instagram for OauthAccount ##{instagram.id}"
        }
      
        ManybotsServer.queue.enqueue(InstagramWorker, instagram.id)
      end
      
      instagram.save
      
      redirect_to root_path, :notice => message
    end
    
    
    def destroy
      instagram = current_user.oauth_accounts.find(params[:id])
      load_schedule(instagram)
      ManybotsServer.queue.remove_schedule @schedule_name if @schedule
      instagram.destroy
      redirect_to root_path, notice: 'Account deleted.'
    end
    
  private
  
    def configure_instagram
      Instagram.configure do |config|
        config.client_id = ManybotsInstagram.instagram_app_id
        config.client_secret = ManybotsInstagram.instagram_app_secret
      end
    end
    
    def instagram_callback_url
      "#{ManybotsInstagram.app.url}/instagram/callback"
    end
    
    def current_app
      @manybots_instagram_app ||= ManybotsInstagram.app
    end
        
    def load_schedules
      ManybotsServer.queue.get_schedules
    end
    
    def load_schedule(oauth_account)
      schedules = load_schedules
      @schedule_name = "import_manybots_instagram_#{oauth_account.id}"
      @schedule = schedules.keys.include?(@schedule_name) rescue(false)
    end
    
    
  end
end
