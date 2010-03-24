require 'rubygems'
require 'action_controller'
require 'action_view'
require File.join(File.dirname(__FILE__), '../lib/bot-proof-forms')

ActionController::Routing::Routes.load!
ActionController::Base.session = { :key => "_myapp_session", :secret => "12345"*6 }

$LOAD_PATH << File.join(File.dirname(__FILE__), 'support/controllers')
ActiveSupport::Dependencies.load_paths <<  File.join(File.dirname(__FILE__), 'support/controllers')

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each do |fi|
  require fi
end

all_routes = ENV['CONTROLLER'] ? ActionController::Routing::Routes.routes.select { |route| route.defaults[:controller] == ENV['CONTROLLER'] } : ActionController::Routing::Routes.routes
routes = all_routes.collect do |route|
  name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
  verb = route.conditions[:method].to_s.upcase
  segs = route.segments.inject("") { |str,s| str << s.to_s }
  segs.chop! if segs.length > 1
  reqs = route.requirements.empty? ? "" : route.requirements.inspect
  {:name => name, :verb => verb, :segs => segs, :reqs => reqs}
end
name_width = routes.collect {|r| r[:name]}.collect {|n| n.length}.max
verb_width = routes.collect {|r| r[:verb]}.collect {|v| v.length}.max
segs_width = routes.collect {|r| r[:segs]}.collect {|s| s.length}.max
routes.each do |r|
  puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:segs].ljust(segs_width)} #{r[:reqs]}"
end
