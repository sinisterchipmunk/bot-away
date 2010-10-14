require 'spec_helper'

describe "Bot-Away" do
  # Basically we're just switching BA on and off, so we only need 2 sets of tests: what to expect when it's on, and
  # what to expect when it's off. The rest of this file just flips the switches.
  
  def test_params
    {"model"=>"User", "commit"=>"Sign in",
     "authenticity_token"=>"XBQEDkXrm4E8U9slBX45TWNx7TPcx8ww2FSJRy/XXg4=",
     "action"=>"index", "controller"=>"test", "user"=>{"username"=>"admin", "password"=>"Admin01"}
    }
  end
  
  def self.it_should_be_disabled
    it "should not obfuscate the field, because it should be disabled" do
      builder.text_field('method_name').should_not match(/name="#{obfuscated_name}/)
    end
    
    it "should not drop invalid params, because it should be disabled" do
      parms = BotAway::ParamParser.new('127.0.0.1', test_params).params
      parms.should == test_params
    end

    it "should be disabled" do
      BotAway.disabled_for?(:controller => 'test', :action => "index").should == true
    end
  end
  
  def self.it_should_be_enabled
    it "should obfuscate the field, because it should be enabled" do
      builder.text_field('method_name').should be_obfuscated_as(obfuscated_id, obfuscated_name)
    end
    
    it "should drop invalid params, because it should be enabled" do
      parms = BotAway::ParamParser.new('127.0.0.1', test_params).params
      parms.should_not == test_params
    end

    it "should be disabled" do
      BotAway.disabled_for?(:controller => 'test', :action => "index").should == false
    end
  end
  
  # flip-switching begins
  
  context "with matching controller name" do
    context "and no action" do
      before(:each) { BotAway.disabled_for :controller => 'test' }
      it_should_be_disabled
    end
    
    context "and matching action" do
      before(:each) { BotAway.disabled_for :controller => 'test', :action => 'index' }
      it_should_be_disabled
    end
    
    context "and not matching action" do
      before(:each) { BotAway.disabled_for :controller => 'test', :action => 'create' }
      it_should_be_enabled
    end
  end
  
  context "with not matching controller name" do
    context "and no action" do
      before(:each) { BotAway.disabled_for :controller => 'users' }
      it_should_be_enabled
    end
    
    context "and matching action" do
      before(:each) { BotAway.disabled_for :controller => 'users', :action => 'index' }
      it_should_be_enabled
    end
    
    context "and not matching action" do
      before(:each) { BotAway.disabled_for :controller => 'users', :action => 'create' }
      it_should_be_enabled
    end
  end

  context "with no controller name" do
    context "and matching action" do
      before(:each) { BotAway.disabled_for :action => 'index' }
      it_should_be_disabled
    end
    
    context "and not matching action" do
      before(:each) { BotAway.disabled_for :action => 'create' }
      it_should_be_enabled
    end
  end
  
  context "with matching mode" do
    before(:each) { BotAway.disabled_for :mode => ENV['RAILS_ENV'] }
    it_should_be_disabled
  end

  context "with not matching mode" do
    before(:each) { BotAway.disabled_for :mode => "this_is_not_#{ENV['RAILS_ENV']}" }
    it_should_be_enabled
  end
end
