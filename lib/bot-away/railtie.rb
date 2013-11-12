module BotAway
  class Railtie < Rails::Railtie
    initializer "bot_away.add_middleware" do |app|
      app.middleware.use BotAway::Middleware
    end
  end
end
