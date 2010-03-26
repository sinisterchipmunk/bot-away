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

    def self.should_obfuscate(type, result = '4644938bcf10443347cf092b6eb11e6b[550d0c771b007a3ba3af86d726bd4058]',
            message = "produces obfuscated #{type} element", &block)
      it message do
        @response.template.send(:fields_for, :post, :url => { :action => 'proc_form' }) do |f|
          puts(t = yield(f))
          t.should match(/name="#{Regexp::escape result}"/)
        end
      end
    end

    %w(hidden_field text_field text_area file_field password_field check_box).each do |field|
      should_obfuscate(field) { |f| f.send(field, :field) }
    end
    should_obfuscate(:radio_button) do |f|
      f.radio_button :field, :value
    end

    it "links labels to their obfuscated elements" do
      @response.template.send(:fields_for, :post, :url => { :action => 'proc_form' }) do |f|
        puts(t = f.label(:field))
        t.should match(/for=\"4644938bcf10443347cf092b6eb11e6b_550d0c771b007a3ba3af86d726bd4058\"/)
      end
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
      @response.template.controller.params.should be_empty
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
