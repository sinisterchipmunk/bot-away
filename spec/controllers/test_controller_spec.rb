require 'spec_helper'

describe TestController do
  include ActionController::TestProcess

  def prepare!(action = 'index', method = 'get')
    @controller.request = @request
    @controller.params = {}
    @controller.send(:initialize_current_url)
    send(method, action)
    if @response.template.instance_variable_get("@exception")
      raise @response.template.instance_variable_get("@exception")
    end
  end

  before :each do
    @request = ActionController::TestRequest.new
    # can the authenticity token so that we can predict the generated element names
    @request.session[:_csrf_token] = 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo='
    @request.remote_addr = '208.77.188.166' # example.com
    @response = ActionController::TestResponse.new
    @controller = TestController.new
  end

  after :each do
    # effectively disables forgery protection.
    TestController.request_forgery_protection_token = nil
  end
  
  context "with a model" do
    context "with forgery protection" do
      before :each do
        (class << @controller; self; end).send(:protect_from_forgery)
        prepare!('model_form')
      end

      it "should work?" do
        puts @response.body
      end
    end

    context "without forgery protection" do
      before :each do
        prepare!('model_form')
      end

      it "should work?" do
        puts @response.body
      end
    end
  end

  context "with forgery protection" do
    before :each do
      (class << @controller; self; end).send(:protect_from_forgery)
      prepare!
    end
    
    it "processes valid obfuscated form post" do
      form = { 'authenticity_token' => 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo=',
               'test' => { 'name' => '' },
               'ccd346990f191d7a89a8fc555acd7cfe' => { '223c595232840668232310c41665996e' => 'colin' }
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params.should_not be_empty
    end

    it "drops invalid obfuscated form post" do
      form = { 'authenticity_token' => 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo=',
               'test' => { 'name' => 'test' },
               'ccd346990f191d7a89a8fc555acd7cfe' => { '223c595232840668232310c41665996e' => 'test' }
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params.should == { 'suspected_bot' => true }
    end
  end

  context "without forgery protection" do
    before :each do
      prepare!
    end

    it "processes non-obfuscated form post" do
      form = { 'authenticity_token' => 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo=',
               'test' => { 'name' => 'test' }
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params.should_not be_empty
    end

    it "produces non-obfuscated form elements" do
      @response.body.should_not match(/<\/div><input/)
    end
  end
end
