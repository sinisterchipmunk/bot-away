require 'spec_helper'

describe TestController do
  include ActionController::TestProcess

  def prepare!(action = 'index')
    @controller.request = @request
    @controller.params = {}
    @controller.send(:initialize_current_url)
    get action
    if @response.template.instance_variable_get("@exception")
      raise @response.template.instance_variable_get("@exception")
    end
  end

  before :each do
    @request = ActionController::TestRequest.new
    @request.remote_addr = '208.77.188.166' # example.com
    @response = ActionController::TestResponse.new
    @controller = TestController.new
  end

  after :each do
    # effectively disables forgery protection.
    TestController.request_forgery_protection_token = nil
  end

  context "with forgery protection" do
    before :each do
      (class << @controller; self; end).send(:protect_from_forgery)
      prepare!
    end

    it "test" do
      puts @response.body
      @response.body.should match(/<\/div><input/)
    end
  end

  context "without forgery protection" do
    before :each do
      prepare!
    end

    it "test" do
      puts @response.body
      @response.body.should_not match(/<\/div><input/)
    end
  end
end
