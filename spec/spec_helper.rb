ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../gemfiles/Gemfile.rails-3.1.x", File.dirname(__FILE__))
require 'bundler'
Bundler.setup

ENV['RAILS_ENV'] = 'development'

require 'rails'
require 'active_support'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'bot-away'

# only for Rails 3.0.x
begin; require 'active_support/secure_random'; rescue LoadError; end

class BotAway::TestRailsApp < Rails::Application
  base = File.expand_path("test_rails_app", File.dirname(__FILE__))
  config.secret_token = "some secret phrase of at least 30 characters" * 30
  config.active_support.deprecation = :log
  config.paths['app/controllers'] = File.join(base, 'app/controllers')
  config.paths['app/views']       = File.join(base, 'app/views')
  config.paths['config/locales']  = File.join(base, 'config/locales/bot-away-overrides.yml')
  if Rails::VERSION::MINOR == 0 # rails 3.0.x
    config.paths.app.views        = File.join(base, 'app/views')
    config.paths.config.locales   = File.join(base, 'config/locales/bot-away-overrides.yml')
  end
  config.action_dispatch.show_exceptions = false
end

BotAway::TestRailsApp.initialize!
Rails.application.routes.draw { match '/:controller/:action(/:id)' }
Rails.application.routes.finalize!
Dir[File.expand_path('test_rails_app/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.before do
    # for the CSRF token, which BA uses as a seed
    SecureRandom.stub(:base64).and_return("1234")
    # reset any config changes
    BotAway.reset!
    enable_forgery_protection
  end

  config.include BotAway::TestCase
end
