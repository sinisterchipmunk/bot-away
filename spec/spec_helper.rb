require 'bundler'
Bundler.setup

ENV['RAILS_ENV'] = 'development'

require 'rails'
require 'active_support/secure_random'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require File.expand_path('../lib/bot-away', File.dirname(__FILE__))

class BotAway::TestRailsApp < Rails::Application
  base = File.expand_path("test_rails_app", File.dirname(__FILE__))
  config.paths['app/controllers'] = File.join(base, 'app/controllers')
  config.paths['app/views']       = File.join(base, 'app/views')
  config.active_support.deprecation = :log
end

BotAway::TestRailsApp.initialize!
Rails.application.routes.draw { root :to => 'tests#basic_form' }
Rails.application.routes.finalize!
Dir[File.expand_path('test_rails_app/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

require 'rspec/rails'

RSpec.configure do |config|
  config.before do
    # reset any config changes
    BotAway.reset!
    
    # for the CSRF token, which BA uses as a seed
    SecureRandom.stub!(:base64).and_return("1234")
  end
end
