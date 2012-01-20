require 'spec_helper'

describe "GET params" do
  before do
    visit '/tests/proc_form/1?one=1'
  end
  
  it "should show the params" do
    page.should have_content("id: '1'")
    page.should have_content("one: '1'")
    page.should_not have_content("suspected_bot")
  end
end
