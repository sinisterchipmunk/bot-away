$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' unless defined?(Gem)
require 'action_controller'
require 'action_view'
require 'sc-core-ext'

#require 'bot-proof-forms/builder/honeypots'
#require 'bot-proof-forms/builder'
require 'bot-proof-forms/param_parser'
require 'bot-proof-forms/action_controller/request'
require 'bot-proof-forms/action_view/helpers/instance_tag'
require 'bot-proof-forms/spinner'

module BotProofForms
  VERSION = '0.0.1'
end

#ActionView::Base.default_form_builder = BotProofForms::Builder

# WHY do I have to do this???
ActionView::Base.send :include, ActionView::Helpers
