require 'spec_helper'

# For all intents and purposes this is a view spec, but because rspec mocks up the controller
# in view specs (and rightly so!), we need to technically run it as a controller spec in order
# to invoke a real controller first.
describe TestsController do
  include BotAway::TestCase::ControllerTestCase
  render_views
  before { enable_forgery_protection }
  
  let(:params) { { :controller => 'tests', :action => 'basic_form' } }

  it "should use forgery protection" do # sanity check
    subject.send(:protect_against_forgery?).should be_true
  end
  
  shared_examples_for "enabled" do
    it "returns false when queried for disablement" do
      BotAway.should_not be_disabled_for(params)
      BotAway.should_not be_excluded(params)
    end
    
    it "obfuscates the elements" do
      get 'basic_form'
      response.body.should =~ /id="c89ca970ba19a4174d332aa8cfbd0c42"/ # user_login
      response.body.should =~ /id="f41749ab8ef9d2358cfd170fd9af2f5e"/ # user_password
    end
  end
  
  shared_examples_for "disabled" do
    it "returns true when queried for disablement" do
      # ..."disablement"?
      BotAway.should be_disabled_for(params)
      BotAway.should be_excluded(params)
    end
    
    it "does not obfuscate the elements" do
      get 'basic_form'
      response.body.should_not =~ /id="c89ca970ba19a4174d332aa8cfbd0c42"/ # user_login
      response.body.should_not =~ /id="f41749ab8ef9d2358cfd170fd9af2f5e"/ # user_password
    end
  end
  
  context "with bot-away disabled for only this view" do
    before { BotAway.disabled_for({:controller => 'tests', :action => 'basic_form'}) }
    it_should_behave_like "disabled"
  end
  
  context "with bot-away enabled for all views" do
    it_should_behave_like "enabled"
  end
  
  
  
  
  
  context "with matching controller name" do
    context "and no action" do
      before { BotAway.disabled_for :controller => 'tests' }
      it_should_behave_like "disabled"
    end
    
    context "and matching action" do
      before { BotAway.disabled_for :controller => 'tests', :action => 'basic_form' }
      it_should_behave_like "disabled"
    end
    
    context "and not matching action" do
      before { BotAway.disabled_for :controller => 'tests', :action => 'create' }
      it_should_behave_like "enabled"
    end
  end
  
  context "with not matching controller name" do
    context "and no action" do
      before { BotAway.disabled_for :controller => 'users' }
      it_should_behave_like "enabled"
    end
    
    context "and matching action" do
      before { BotAway.disabled_for :controller => 'users', :action => 'basic_form' }
      it_should_behave_like "enabled"
    end
    
    context "and not matching action" do
      before { BotAway.disabled_for :controller => 'users', :action => 'create' }
      it_should_behave_like "enabled"
    end
  end
  
  context "with no controller name" do
    context "and matching action" do
      before { BotAway.disabled_for :action => 'basic_form' }
      it_should_behave_like "disabled"
    end
    
    context "and not matching action" do
      before { BotAway.disabled_for :action => 'create' }
      it_should_behave_like "enabled"
    end
  end
  
  context "with matching mode" do
    before { BotAway.disabled_for :mode => ENV['RAILS_ENV'] }
    it_should_behave_like "disabled"
  end
  
  context "with not matching mode" do
    before { BotAway.disabled_for :mode => "this_is_not_#{ENV['RAILS_ENV']}" }
    it_should_behave_like "enabled"
  end
end
