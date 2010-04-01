require 'rubygems'
require 'action_controller'
require 'action_view'

ActionController::Routing::Routes.load!
ActionController::Base.session = { :key => "_myapp_session", :secret => "12345"*6 }

require File.join(File.dirname(__FILE__), '../lib/bot-away')

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each do |fi|
  require fi
end
