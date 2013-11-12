require 'bot-away/monkey/action_view/helpers/tag_helper'
require 'bot-away/monkey/action_view/helpers/form_tag_helper'
require 'bot-away/railtie'

module BotAway
  autoload :Middleware,  'bot-away/middleware'
  autoload :ParamParser, 'bot-away/param_parser'
  autoload :Spinner,     'bot-away/spinner'
  autoload :TimeHelpers, 'bot-away/time_helpers'
  autoload :Version,     'bot-away/version'
  autoload :VERSION,     'bot-away/version'

  OBFUSCATED_TAGS = %w( input select textarea )

  @time_increment = 1.second
  @max_form_age = 15.minutes
  @enabled = true

  class << self
    attr_accessor :time_increment
    attr_accessor :max_form_age
    attr_accessor :enabled
  end
end
