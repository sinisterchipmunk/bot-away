$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

#require 'bot-proof-forms/builder'

module BotProofForms
  VERSION = '0.0.1'
end

#ActionView::Base.default_form_builder = BotProofForms::Builder
