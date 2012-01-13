module BotAway::TestCase::InstanceTagTestCase
  def dump
    result = yield
    puts result if ENV['DUMP']
    result
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

  def self.included(base)
    base.module_eval do
      include RSpec::Rails::ViewExampleGroup
    end
  end
  
  def mock_object
    @mock_object ||= BotAway::TestCase::MockObject.new
  end

  def default_instance_tag
    ActionView::Helpers::InstanceTag.new("object_name", "method_name", view, mock_object)
  end
end
