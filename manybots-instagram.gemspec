$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "manybots-instagram/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "manybots-instagram"
  s.version     = ManybotsInstagram::VERSION
  s.authors     = ["Alexandre L. Solleiro"]
  s.email       = ["alex@webcracy.org"]
  s.homepage    = "https://github.com/manybots/manyotts-gmail"
  s.summary     = "Add an Instagram Observer to your local Manybots."
  s.description = "Import your photos from Instagram into your local Manybots."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency "instagram"

  s.add_development_dependency "sqlite3"
end
