require 'bundler'
Bundler.setup

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start { add_filter 'features/' }

require 'pp'
require 'rails'
require 'active_support/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_model/railtie'
require 'bot-away'

class RailsApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = '123' * 30
  config.action_dispatch.show_exceptions = false
  config.root = File.expand_path('../../../tmp/rails_app', __FILE__)
  config.paths['app/views'].unshift Rails.root.join('app/views')
end

RailsApp.initialize!

require 'cucumber/rspec/doubles'
require 'capybara/cucumber'
require 'capybara/rails'
