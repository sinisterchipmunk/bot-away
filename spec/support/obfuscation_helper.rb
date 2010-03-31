module ObfuscationHelper
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

  def dump
    returning(yield) { |x| puts x }
  end

  def builder
    return @builder if @builder
    response = TestController.call(Rack::MockRequest.env_for('/').merge({'REQUEST_URI' => '/',
                                                                         'REMOTE_ADDR' => '127.0.0.1'}))
    response.template.controller.request_forgery_protection_token = :authenticity_token
    response.template.controller.session[:_csrf_token] = '1234'
    @builder = ActionView::Helpers::FormBuilder.new(:object_name, MockObject.new, response.template, {}, proc {})
  end

  def obfuscates(method, obfuscated_id = self.obfuscated_id, obfuscated_name = self.obfuscated_name)
    value = yield
    context "##{method}" do
      subject { proc { dump { value } } }

      includes_honeypot(object_name, method_name)
      is_obfuscated_as(obfuscated_id, obfuscated_name)
    end
  end

  def obfuscated_id
    "e21372563297c728093bf74c3cb6b96c"
  end

  def obfuscated_name
    "a0844d45bf150668ff1d86a6eb491969"
  end

  def object_name
    "object_name"
  end

  def method_name
    "method_name"
  end
end

Spec::Runner.configure do |config|
  config.extend  ObfuscationHelper
  config.include ObfuscationHelper
end
