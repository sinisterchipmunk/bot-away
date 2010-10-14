require 'spec_helper'

describe ActionView::Helpers::FormBuilder do
  subject { builder }
  
  context "testing #disabled_for" do
    subject { builder.text_field('method_name') }
    
    def self.it_should_be_disabled
      it "should not obfuscate the field, because it should be disabled" do
        subject.should_not match(/name="#{obfuscated_name}/)
      end
    end
    
    def self.it_should_be_enabled
      it "should obfuscate the field, because it should be enabled" do
        subject.should be_obfuscated_as(obfuscated_id, obfuscated_name)
      end
    end
    
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
end
