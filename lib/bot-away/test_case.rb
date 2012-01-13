module BotAway::TestCase
  autoload :ControllerTestCase,  'bot-away/test_case/controller_test_case'
  autoload :InstanceTagTestCase, 'bot-away/test_case/instance_tag_test_case'
  autoload :MockObject,          'bot-away/test_case/mock_object'
  
  def enable_forgery_protection
    # BotAway doesn't work without forgery protection, and RSpec-Rails 2 disables it.
    # Lost way too many hours on this.
    # Note: This has to happen in spec file because RSpec2 sets a before block, which runs
    # after the ones set by config.
    Rails.application.config.allow_forgery_protection = true
    ActionController::Base.allow_forgery_protection = true
  end
  
  def disable_forgery_protection
    Rails.application.config.allow_forgery_protection = false
    ActionController::Base.allow_forgery_protection = false
  end
end
