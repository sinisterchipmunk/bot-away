module BotAway::TestCase::InstanceTagTestCase
  def self.included(base)
    base.module_eval do
      include RSpec::Rails::ViewExampleGroup
    end
  end
  
  def mock_object
    @mock_object ||= BotAway::TestCase::MockObject.new
  end

  def default_instance_tag
    @default_instance_tag ||= ActionView::Helpers::InstanceTag.new("object_name", "method_name", view, mock_object)
  end
end
