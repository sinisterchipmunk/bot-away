require 'rails/engine'
require 'rails/version'

class BotAway::Railtie < Rails::Engine
  if Rails::VERSION::MINOR == 0 # Rails 3.0.x
    paths.config.locales    = File.expand_path("../locale/honeypots.yml", File.dirname(__FILE__))
  else
    paths["config/locales"] = File.expand_path("../locale/honeypots.yml", File.dirname(__FILE__))
  end
end
