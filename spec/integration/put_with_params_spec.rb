require 'spec_helper'

describe "PUT params" do
  before do
    visit '/tests/model_form/1'
  end
  
  describe "filling in a honeypot" do
    before do
      fill_in 'post[subject]', :with => "this is a subject"
      click_button 'submit'
    end
    
    it "should be considered a bot" do
      page.should have_content('suspected_bot')
    end
    
    it "should not include legit params" do
      page.should_not have_content("subject:")
    end
    
    it "should drop data from the honeypots" do
      page.should_not have_content("this is a subject")
    end

    it "should drop the hidden value" do
      page.should_not have_content('hidden_value')
    end
  end

  describe "filling in a legit field" do
    before do
      fill_in '00a1168ac1379bdbe9b59e678fe486b1', :with => "this is a subject"
      click_button 'submit'
    end
    
    it "should include the hidden value" do
      page.should have_content('hidden_value')
    end
    
    it "should have kept legit data" do
      page.should have_content('this is a subject')
    end
    
    it "should not be considered a bot" do
      page.should_not have_content('suspected_bot')
    end
  end
end
