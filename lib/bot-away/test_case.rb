module BotAway::TestCase
  autoload :ControllerTestCase,  'bot-away/test_case/controller_test_case'
  autoload :InstanceTagTestCase, 'bot-away/test_case/instance_tag_test_case'
  autoload :MockObject,          'bot-away/test_case/mock_object'
  autoload :Matchers,            'bot-away/test_case/matchers'
  
  def builder
    @builder ||= ActionView::Base.default_form_builder.new(object_name, mock_object, view, {}, proc {})
  end

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
  
  def mock_object
    @mock_object ||= MockObject.new
  end

  def obfuscated_id
    "f51a02a636f507f1bd64722451b71297"
  end

  def obfuscated_name
    "cd538a9170613d6dedbcc54a0aa24881"
  end
  
  def object_name
    "object_name"
  end

  def method_name
    "method_name"
  end
  
  def tag_id
    "#{object_name}_#{method_name}"
  end
  
  def tag_name
    "#{object_name}[#{method_name}]"
  end

  def dump
    result = yield
    puts result if ENV['DUMP']
    result
  end
end
