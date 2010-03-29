module ObfuscationHelper
  def includes_honeypot(object_name, method_name)
    it "includes a honeypot called #{object_name}[#{method_name}]" do
      subject.should include_honeypot(object_name, method_name)
    end
  end

  def is_obfuscated_as(object_name, method_name)
    it "is obfuscated as #{object_name}[#{method_name}]" do
      subject.should be_obfuscated_as(object_name, method_name)
    end
  end

  def dump
    returning(yield) { |x| puts x }
  end

  def builder
    return @builder if @builder
    response = TestController.call(Rack::MockRequest.env_for('/').merge({'REQUEST_URI' => '/',
                                                                         'REMOTE_ADDR' => '127.0.0.1'}))
    response.template.controller.request_forgery_protection_token = :authenticity_token
    response.template.controller.session[:_csrf_token] = '1234'
    @builder = BotProofForms::Builder.new(:object_name, MockObject.new, response.template, {}, proc {})
  end

  def obfuscates(method)
    value = yield
    context "##{method}" do
      subject { proc { dump { value } } }

      includes_honeypot(object_name, method_name)
      is_obfuscated_as(obfuscated_object_name, obfuscated_method_name)
    end
  end

  def obfuscated_object_name
    "50206624c6a61ddd6f3e6eddb2ac02d3"
  end

  def obfuscated_method_name
    "76042ec523072e08e3313cb0ea54aca6"
  end

  def object_name
    "object_name"
  end

  def method_name
    "method_name"
  end
end

Spec::Runner.configure do |config|
  config.include ObfuscationHelper
  config.extend  ObfuscationHelper
end
