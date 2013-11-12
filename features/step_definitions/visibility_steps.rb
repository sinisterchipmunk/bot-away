Then(/^I should see "(.*?)"$/) do |text|
  page.should have_text text
end

Then(/^the response should contain "(.*?)"$/) do |arg1|
  page.should have_text arg1
end
