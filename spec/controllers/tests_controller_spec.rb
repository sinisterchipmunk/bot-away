require 'spec_helper'

describe TestsController do
  include BotAway::TestCase::ControllerTestCase
  
  before do
    disable_forgery_protection
    request.session[:_csrf_token] = 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo='
    request.remote_addr = '208.77.188.166'
  end
  
  context "with a model" do
    render_views
    
    context "with forgery protection" do
      before do
        enable_forgery_protection
        get 'model_form'
      end

      it "should work?" do
        response.body.should =~ /<select/
      end
    end

    context "without forgery protection" do
      before do
        get 'model_form'
      end

      it "should work?" do
        response.body.should =~ /<select/
      end
    end
  end

  context "with forgery protection" do
    before { enable_forgery_protection }

    #"object_name_method_name" name="object_name[method_name]" size="30" type="text" value="" /></div>
    #<input id="e21372563297c728093bf74c3cb6b96c" name="a0844d45bf150668ff1d86a6eb491969" size="30" type="text" value="method_value" />
    
    it "processes valid obfuscated form post" do
      form = { 'authenticity_token' => '1234',
               'object_name' => { 'method_name' => '' },
               '842d8d1c80014ce9f3d974614338605c' => 'some_value'
             }
      post 'proc_form', form
      #puts response.body
      controller.params[:object_name].should == { 'method_name' => 'some_value' }
    end
    
    context "after processing valid obfuscated post" do
      before do
        post 'proc_form', { 'authenticity_token' => '1234',
                 'object_name' => { 'method_name' => '' },
                 '842d8d1c80014ce9f3d974614338605c' => 'some_value'
        }
      end
      it "should allow params to be changed" do
        # Whether it's best practice or not, the Rails params hash can normally be modified from the controller.
        # So, it makes sense to verify that BotAway doesn't change this.
        controller.params[:object_name][:method_name] = "a different value"
        controller.params[:object_name][:method_name].should == "a different value"
        
        controller.params.clear
        controller.params.should == {}
      end
    end

    it "drops invalid obfuscated form post" do
      form = { 'authenticity_token' => '1234',
               'object_name' => { 'method_name' => 'a bot filled this in' },
               '842d8d1c80014ce9f3d974614338605c' => 'some_value'
             }
      post 'proc_form', form
      controller.params['suspected_bot'].should == true
      controller.params.keys.should_not include('object_name')
    end

    it "processes no params" do
      post 'proc_form', { 'authenticity_token' => '1234' }
      controller.params['suspected_bot'].should_not == true
    end

    it "should not fail on unfiltered params" do
      BotAway.accepts_unfiltered_params :role_ids
      @request.remote_addr = '127.0.0.1'
      post 'proc_form', {'authenticity_token' => '1234', 'user' => { 'role_ids' => [1, 2] }}
      controller.params['suspected_bot'].should_not == true
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
      controller.request.remote_addr = '127.0.0.1'
      post 'proc_form', form
      # puts controller.params.inspect
      controller.params.should == { 'action' => 'proc_form', 'controller' => 'tests',
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
    it "processes non-obfuscated form post" do
      form = { #'authenticity_token' => '1234',
               'object_name' => { 'method_name' => 'test' }
             }
      post 'proc_form', form
      # puts response.body
      controller.params.should_not == { 'suspected_bot' => true }
      controller.params[:object_name].should == { 'method_name' => 'test' }
    end

    it "produces non-obfuscated form elements" do
      response.body.should_not match(/<\/div><input/)
    end
  end
end
