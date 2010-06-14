$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' unless defined?(Gem)
require 'action_controller'
require 'action_view'
require 'sc-core-ext'

require 'bot-away/param_parser'
require 'bot-away/action_controller/request'
require 'bot-away/action_view/helpers/instance_tag'
require 'bot-away/spinner'

module BotAway
  VERSION = '1.0.3'
end

# WHY do I have to do this???
ActionView::Base.send :include, ActionView::Helpers
