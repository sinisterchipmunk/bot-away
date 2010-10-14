ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'action_controller'
require 'action_view'

begin
  # rails 2.x
  ActionController::Routing::Routes.load!
  ActionController::Base.session = { :key => "_myapp_session", :secret => "12345"*6 }
  ActionController::Base.view_paths << File.expand_path(File.join(File.dirname(__FILE__), "support/views"))
  RAILS_VERSION = "2.3"
rescue
  # rails 3
  #require 'active_record/railtie'
  require 'action_controller/railtie'
  require 'action_mailer/railtie'
  require 'active_resource/railtie'
  require 'rails/test_unit/railtie'

  # stub out the csrf token so that it always produces a predictable (testable) result
  module ActionView
    # = Action View CSRF Helper
    module Helpers
      module CsrfHelper
        # Returns a meta tag with the cross-site request forgery protection token
        # for forms to use. Place this in your head.
        def csrf_meta_tag
          if protect_against_forgery?
            %(<meta name="csrf-param" content="#{Rack::Utils.escape_html(request_forgery_protection_token)}"/>\n<meta name="csrf-token" content="1234"/>).html_safe
          end
        end
      end
    end
  end

  class BotAwayApp < Rails::Application
    config.session_store :cookie_store, :key => "_myapp_session", :secret => "12345"*6
    paths.app.views = File.expand_path(File.join(File.dirname(__FILE__), "support/views"))
    config.active_support.deprecation = :stderr
  end
  BotAwayApp.initialize!
  BotAwayApp.routes.draw do
    match '/:controller/:action'
  end
  
  RAILS_VERSION = "3.0"
end

require File.join(File.dirname(__FILE__), '../lib/bot-away')
require File.join(File.dirname(__FILE__), "rspec_version")

class MockObject
  attr_accessor :method_name
  
  def id
    1
  end
  
  # for testing grouped_collection_select
  def object_name
    [self]
  end

  def initialize
    @method_name = 'method_value'
  end
end


if RSPEC_VERSION < "2.0"
  Spec::Runner.configure do |config|
    config.before(:each) do
      BotAway.reset!
    end
  end
  
  if defined?(ActionController::TestProcess)
    # note that this only matters for TEST requests; real ones use the params parser.
    module ActionController::TestProcess
      def process_with_deobfuscation(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
        process_without_deobfuscation(action, parameters, session, flash, http_method)
        @request.parameters.replace(BotAway::ParamParser.new(@request.ip, @request.params).params)
      end
    
      alias_method_chain :process, :deobfuscation
    end
  end
else
  require 'rspec/rails'
  
  # note that this only matters for TEST requests; real ones use the params parser.
  module ActionController::TestCase::Behavior
    def process_with_deobfuscation(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      process_without_deobfuscation(action, parameters, session, flash, http_method)
      request.parameters.replace(BotAway::ParamParser.new(request.ip, request.params).params)
    end
    
    alias_method_chain :process, :deobfuscation
  end
      
  RSpec.configure do |config|
    config.before(:each) do
      BotAway.reset!
      # BotAway doesn't work without forgery protection, and RSpec-Rails 2 disables it. Lost way too many hours on this.
      ActionController::Base.allow_forgery_protection = true
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each do |fi|
  require fi
end
