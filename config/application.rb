# config/application.rb

require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module SimpleDrive
  class Application < Rails::Application
    config.load_defaults 7.0

    # Add the following line inside the Application class block
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/validators)
    # Other configuration settings...
  end
end