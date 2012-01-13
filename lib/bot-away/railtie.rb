require 'rails/engine'

class BotAway::Railtie < Rails::Engine
  paths["config/locales"] = File.expand_path("../locale/honeypots.yml", File.dirname(__FILE__))
end
