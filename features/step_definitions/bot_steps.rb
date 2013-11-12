Then(/^a bot should be detected$/) do
  step 'the response should contain "bot detected"'
end

Then(/^a bot should not be detected$/) do
  step 'the response should not contain "bot detected"'
end
