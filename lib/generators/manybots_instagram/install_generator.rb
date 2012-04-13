require 'rails/generators'
require 'rails/generators/base'


module ManybotsInstagram
  module Generators
    class InstallGenerator < Rails::Generators::Base
      
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      desc 'Mounts Manybots Instagram at "/manybots-instagram"'
      def add_manybots_gardener_routes
        route 'mount ManybotsInstagram::Engine => "/manybots-instagram"' if options.routes?
      end
      
      desc "Creates a ManybotsInstagram initializer"
      def copy_initializer
        template "manybots-instagram.rb", "config/initializers/manybots-instagram.rb"
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end
      
    end
  end
end
