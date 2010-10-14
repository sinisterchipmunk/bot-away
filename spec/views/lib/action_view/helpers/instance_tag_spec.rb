require 'spec_helper'

describe ActionView::Helpers::InstanceTag do
  if method_defined?(:controller)
    def template
      view
    end
  else
    def template
      return @response if @response
      @response = TestController.call(Rack::MockRequest.env_for('/').merge({'REQUEST_URI' => '/',
                                                                            'REMOTE_ADDR' => '127.0.0.1'}))
      @response.template.controller.request_forgery_protection_token = :authenticity_token
      @response.template.controller.session[:_csrf_token] = '1234'
      @response.template
    end
  end
  
  def mock_object
    @mock_object ||= MockObject.new
  end

  def default_instance_tag
    ActionView::Helpers::InstanceTag.new("object_name", "method_name", template, mock_object)
  end

  subject { default_instance_tag }

  context "with a valid text area tag" do
    subject do
      dump { default_instance_tag.to_text_area_tag }
    end

    it "should produce blank honeypot value" do
      subject.should_not =~ /name="object_name\[method_name\]"[^>]+>method_value<\/textarea>/
    end
  end

  context "with a valid input type=text tag" do
    before(:each) { @tag_options = ["input", {:type => 'text', 'name' => 'object_name[method_name]', 'id' => 'object_name_method_name', 'value' => 'method_value'}] }
    #subject { dump { default_instance_tag.tag(*@tag_options) } }
    
    it "should turn off autocomplete for honeypots" do
      subject.honeypot_tag(*@tag_options).should =~ /autocomplete="off"/
    end

    it "should obfuscate tag name" do
      subject.obfuscated_tag(*@tag_options).should =~ /name="#{obfuscated_name}"/
    end

    it "should obfuscate tag id" do
      subject.obfuscated_tag(*@tag_options).should =~ /id="#{obfuscated_id}"/
    end

#    it "should not obfuscate tag value" do
#      subject.obfuscated_tag(*@tag_options).should =~ /value="@tag_options"/
#    end
#
    it "should include unobfuscated tag value" do
      subject.obfuscated_tag(*@tag_options).should =~ /value="method_value"/
    end

    it "should create honeypot name" do
      subject.honeypot_tag(*@tag_options).should =~ /name="object_name\[method_name\]"/
    end

    it "should create honeypot id" do
      subject.honeypot_tag(*@tag_options).should =~ /id="object_name_method_name"/
    end

    it "should create empty honeypot tag value" do
      subject.honeypot_tag(*@tag_options).should =~ /value=""/
    end
  end
end
