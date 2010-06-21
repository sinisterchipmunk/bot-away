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
  VERSION = '1.1.0'
  
  class << self
    attr_accessor :show_honeypots, :dump_params
    
    def unfiltered_params(*args)
      ActionController::Request.unfiltered_params(*args)
    end
    
    alias accepts_unfiltered_params unfiltered_params
    
    def excluded?(object_name, method_name)
      unfiltered_params.collect! { |u| u.to_s }
      if (object_name &&
              (unfiltered_params.include?(object_name.to_s) ||
                      unfiltered_params.include?("#{object_name}[#{method_name}]")) ||
          unfiltered_params.include?(method_name.to_s))
        true
      else
        false
      end
    end
  end
end

# WHY do I have to do this???
ActionView::Base.send :include, ActionView::Helpers
