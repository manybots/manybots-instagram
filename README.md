# Instagram Observer

manybots-instagram is a Manybots Observer that allows you to import your photos from Instagram to your local Manybots.

## Installation instructions

### Setup the gem

You need the latest version of Manybots Local running on your system. Open your Terminal and `cd` into its' directory.

First, require the gem: edit your `Botfile`, add the following, and run `bundle install`

```
gem 'manybots-instagram', :git => 'git://github.com/manybots/manybots-instagram.git'
gem 'instagram', :git => 'git://github.com/webcracy/instagram-ruby-gem.git'
```

Second, run the manybots-instagram install generator (mind the underscore):

```
rails g manybots_instagram:install
```

Now you need to register your Instagram Observer with Github.

### Register your Instagram Observer with Instagram

Your Instagram Observer uses OAuth to authorize you (and/or your other Manybots Local users) with Instagram. 

Now, register your application with Instagram to get the Client ID and Secret. Go to the [Instagram App Management page](http://instagr.am/developer/manage/) and create a new application.

And then copy-paste the Client ID and Client Secret in the appropriate "replace me" parts.

1. Go to this link: http://instagr.am/developer/manage/

2. Enter information like described in the screenshot below

<img src="https://img.skitch.com/20120413-j8nbngxq1cq2qmwq6s3eikc6q3.png" />

3. Copy the Client ID and Secret into `config/initializers/manybots-instagram.rb`

```
  config.instagram_app_id = 'Client ID'
  config.instagram_app_secret = 'Secret'
```  


### Restart and go!

Restart your server and you'll see the Instagram Observer in your `/apps` catalogue. Go to the app, sign-in to your Instagram account and start importing your photos into Manybots.
