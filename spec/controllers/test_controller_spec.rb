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
    #"object_name_method_name" name="object_name[method_name]" size="30" type="text" value="" /></div>
    #<input id="e21372563297c728093bf74c3cb6b96c" name="a0844d45bf150668ff1d86a6eb491969" size="30" type="text" value="method_value" />
    
    it "processes valid obfuscated form post" do
      form = { 'authenticity_token' => '1234',
               'object_name' => { 'method_name' => '' },
               '842d8d1c80014ce9f3d974614338605c' => 'some_value'
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params[:object_name].should == { 'method_name' => 'some_value' }
    end

    it "drops invalid obfuscated form post" do
      form = { 'authenticity_token' => '1234',
               'object_name' => { 'method_name' => 'test' },
               '842d8d1c80014ce9f3d974614338605c' => 'some_value'
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params.should == { 'suspected_bot' => true }
    end

    it "processes no params" do
      post 'proc_form', { 'authenticity_token' => '1234' }
      @response.template.controller.params.should_not == { 'suspected_bot' => true }
    end

    it "should not fail on unfiltered params" do
      ActionController::Request.accepts_unfiltered_params :role_ids
      @request.remote_addr = '127.0.0.1'
      post 'proc_form', {'authenticity_token' => '1234', 'user' => { 'role_ids' => [1, 2] }}
      @response.template.controller.params.should_not == { 'suspected_bot' => true }
    end

    it "does not drop valid authentication request" do
      #@request.session[:_csrf_token] = 'yPgTAsngzpBO8k1v83RGH26sTrQYD50Ou2oiMT4r/iw='
      form = { 'authenticity_token' => 'yPgTAsngzpBO8k1v83RGH26sTrQYD50Ou2oiMT4r/iw=',
               'user_session' => {
                 'login' => '',
                 'password' => '',
                 'remember_me' => ''
               },
               'commit' => 'Log In',
               '89dce8f562b119a2f88da6d29f535a0d' => 'admin',
               '4b9bab79bc1b1cd5229041c357750e0c' => 'pwpwpw',
               '256307a36284445cc84014dae651f2ed' => '1'
             }
      @request.remote_addr = '127.0.0.1'
      post 'proc_form', form
      puts @response.template.controller.params.inspect
      @response.template.controller.params.should == { 'action' => 'proc_form', 'controller' => 'test',
                                                       'authenticity_token' => 'yPgTAsngzpBO8k1v83RGH26sTrQYD50Ou2oiMT4r/iw=',
                                                       'user_session' => {
                                                          'login' => 'admin',
                                                          'password' => 'pwpwpw',
                                                          'remember_me' => '1'
                                                       },
                                                       'commit' => 'Log In'
      }
    end
  end

  context "without forgery protection" do
    before :each do
      prepare!
    end

    it "processes non-obfuscated form post" do
      form = { #'authenticity_token' => '1234',
               'object_name' => { 'method_name' => 'test' }
             }
      post 'proc_form', form
      puts @response.body
      @response.template.controller.params.should_not == { 'suspected_bot' => true }
      @response.template.controller.params[:object_name].should == { 'method_name' => 'test' }
    end

    it "produces non-obfuscated form elements" do
      @response.body.should_not match(/<\/div><input/)
    end
  end
end
