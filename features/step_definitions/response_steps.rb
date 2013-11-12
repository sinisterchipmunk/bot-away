Then(/^the response should not contain "(.*?)"$/) do |arg1|
  page.should_not have_text arg1
end
