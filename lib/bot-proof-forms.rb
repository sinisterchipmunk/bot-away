$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' unless defined?(Gem)
require 'action_controller'
require 'action_view'
require 'sc-core-ext'

require 'bot-proof-forms/param_parser'
require 'bot-proof-forms/action_controller/request'
require 'bot-proof-forms/action_view/helpers/instance_tag'
require 'bot-proof-forms/spinner'

module BotProofForms
  VERSION = '1.0.0'
end

# WHY do I have to do this???
ActionView::Base.send :include, ActionView::Helpers
