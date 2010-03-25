require 'spec_helper'

describe TestController do
  include ActionController::TestProcess
  
  before :each do
    @request = ActionController::TestRequest.new
    @request.remote_addr = '208.77.188.166' # example.com
    @response = ActionController::TestResponse.new
    @controller = TestController.new
    @controller.request = @request
    @controller.params = {}
    @controller.send(:initialize_current_url)
  end

  it "test" do
    get 'index'
    if @response.template.instance_variable_get("@exception")
      puts @response.template.instance_variable_get("@exception").message
      puts @response.template.instance_variable_get("@exception").backtrace
      
    else
      puts @response.body
    end
  end
end
