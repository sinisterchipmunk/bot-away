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

    it "produces obfuscated form elements" do
      puts @response.body
      @response.body.should match(/<\/div><input/)
    end

    it "processes valid obfuscated form post" do
      form = { 'authenticity_token' => 'aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo=',
               'test' => { 'name' => '' },
               '3d026031f5be275dd715eaa866014d0b' => { '97e969f7b98e5613dec665117746bba6' => 'colin' }
             }
      post 'proc_form', form
      puts @response.body
#        <div style='display:none;'>Leave this empty: <input id="test_name" name="test[name]" size="30" type="text" /></div><input id="3d026031f5be275dd715eaa866014d0b_97e969f7b98e5613dec665117746bba6" name="3d026031f5be275dd715eaa866014d0b[97e969f7b98e5613dec665117746bba6]" size="30" type="text" />
#      </form>
    end

    it "processes invalid obfuscated form post" do
#      <form action="/test/post_to" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="aVjGViz+pIphXt2pxrWfXgRXShOI0KXOILR23yw0WBo=" /></div>
#        <div style='display:none;'>Leave this empty: <input id="test_name" name="test[name]" size="30" type="text" /></div><input id="3d026031f5be275dd715eaa866014d0b_97e969f7b98e5613dec665117746bba6" name="3d026031f5be275dd715eaa866014d0b[97e969f7b98e5613dec665117746bba6]" size="30" type="text" />
#      </form>
    end
  end

  context "without forgery protection" do
    before :each do
      prepare!
    end

    it "processes non-obfuscated form post" do
#      <form action="/test/post_to" method="post">
#        <input id="test_name" name="test[name]" size="30" type="text" />
#      </form>
    end

    it "produces non-obfuscated form elements" do
      #puts @response.body
      @response.body.should_not match(/<\/div><input/)
    end
  end
end
