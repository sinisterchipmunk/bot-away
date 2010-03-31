require 'spec_helper'

def template
  return @response if @response
  @response = TestController.call(Rack::MockRequest.env_for('/').merge({'REQUEST_URI' => '/',
                                                                     'REMOTE_ADDR' => '127.0.0.1'}))
  @response.template.controller.request_forgery_protection_token = :authenticity_token
  @response.template.controller.session[:_csrf_token] = '1234'
  @response.template
end

def mock_object
  @mock_object ||= MockObject.new
end

def default_instance_tag
  ActionView::Helpers::InstanceTag.new("object_name", "method_name", template, mock_object)
end

describe ActionView::Helpers::InstanceTag do
  subject { default_instance_tag }

  context "with a valid input type=text tag" do
    subject do
      dump { default_instance_tag.tag("input", :type => 'text', 'name' => 'object_name[method_name]', 'id' => 'object_name_method_name', 'value' => 'method_value') }
    end

    it "should obfuscate tag name" do
      subject.should =~ /name="a0844d45bf150668ff1d86a6eb491969"/
    end

    it "should obfuscate tag id" do
      subject.should =~ /id="e21372563297c728093bf74c3cb6b96c"/
    end

    it "should not obfuscate tag value" do
      subject.should_not =~ /value="5a6a50d5fd0b5c8b1190d87eb0057e47"/
    end

    it "should include unobfuscated tag value" do
      subject.should =~ /value="method_value"/
    end

    it "should create honeypot name" do
      subject.should =~ /name="object_name\[method_name\]"/
    end

    it "should create honeypot id" do
      subject.should =~ /id="object_name_method_name"/
    end

    it "should create empty honeypot tag value" do
      subject.should =~ /value=""/
    end
  end
end
