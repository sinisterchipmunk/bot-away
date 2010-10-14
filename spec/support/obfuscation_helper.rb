module ObfuscationHelper
  def controller_class
    TestController
  end

  def dump
    result = yield
    puts result if ENV['DUMP']
    result
  end
  
  if RAILS_VERSION >= "3.0"
    def self.included(base)
      base.before(:each) do
        session[:_csrf_token] = '1234'
        controller.stub!(:protect_from_forgery?).and_return(true)
        if respond_to?(:view)
          controller.request.path_parameters["action"] ||= "index"
          controller.action_name ||= "index"
          view.stub!(:request_forgery_protection_token).and_return(:authenticity_token)
          view.stub!(:form_authenticity_token).and_return('1234')
        else
#          response.stub!(:request_forgery_protection_token).and_return(:authenticity_token)
#          response.stub!(:form_authenticity_token).and_return('1234')
        end
      end
    end
  end
  
  def builder
    return @builder if @builder
    if RAILS_VERSION < "3.0"
      response = TestController.call(Rack::MockRequest.env_for('/').merge({'REQUEST_URI' => '/',
                                                                           'REMOTE_ADDR' => '127.0.0.1'}))
      response.template.controller.request_forgery_protection_token = :authenticity_token
      response.template.controller.session[:_csrf_token] = '1234'
      @builder = ActionView::Helpers::FormBuilder.new(:object_name, MockObject.new, response.template, {}, proc {})
    else
      @builder = ActionView::Base.default_form_builder.new(:object_name, MockObject.new, view, {}, proc {})
    end
  end
  
  # this is the obfuscated version of the string "object_name_method_name"
  def obfuscated_id
    self.class.obfuscated_id
  end
  
  # this is the obfuscated version of the string "object_name[method_name]"
  def obfuscated_name
    self.class.obfuscated_name
  end

  def object_name
    self.class.object_name
  end
  
  def method_name
    self.class.method_name
  end
  
  module ClassMethods
    def includes_honeypot(object_name, method_name)
      it "includes a honeypot called #{object_name}[#{method_name}]" do
        subject.should include_honeypot(object_name, method_name)
      end
    end

    def is_obfuscated_as(id, name)
      it "is obfuscated as #{id}, #{name}" do
        subject.should be_obfuscated_as(id, name)
      end
    end
  
    def obfuscates(method, options = {}, unused = nil, &block)
      if !options.kind_of?(Hash)
        options = { :obfuscated_id => options, :obfuscated_name => unused }
      end
      
      obfuscated_id   = options[:obfuscated_id]  || self.obfuscated_id
      obfuscated_name = options[:obfuscatd_name] || self.obfuscated_name
      
      context "##{method}" do
        before(:each) { @obfuscates_value = instance_eval(&block) }
        subject { proc { dump { @obfuscates_value } } }
        
        if options[:name]
          includes_honeypot(options[:name], nil)
        else
          includes_honeypot(options[:object_name] || object_name, options[:method_name] || method_name)
        end
        is_obfuscated_as(obfuscated_id, obfuscated_name)
      end
    end

    def obfuscated_id
      RAILS_VERSION >= "3.0" ? "f51a02a636f507f1bd64722451b71297" : "e21372563297c728093bf74c3cb6b96c"
    end
  
    def obfuscated_name
      RAILS_VERSION >= "3.0" ? "cd538a9170613d6dedbcc54a0aa24881" : "a0844d45bf150668ff1d86a6eb491969"
    end
    
    def object_name
      "object_name"
    end
  
    def method_name
      "method_name"
    end
  end
end

if RSPEC_VERSION < "2.0"
  Spec::Runner.configure do |config|
    config.extend  ObfuscationHelper::ClassMethods
    config.include ObfuscationHelper
  end
else
  RSpec.configure do |config|
    config.extend ObfuscationHelper::ClassMethods
    config.include ObfuscationHelper
  end
end
