Then(/^there should be an obfuscated text field for "(.*?)"$/) do |arg1|
  model_name, field_name = arg1.split ' '
  name = "#{model_name}[#{field_name}]"
  id = [ model_name, field_name ].join '_'
  name = BotAway::Spinner.spin name
  id = BotAway::Spinner.spin id

  page.should have_css 'input[type=text][name="%s"][id="%s"]' % [ name, id ]
end

Then(/^there should be an obfuscated label for "(.*?)"$/) do |arg1|
  model_name, field_name = arg1.split ' '
  name = "#{model_name}[#{field_name}]"
  id = [ model_name, field_name ].join '_'
  id = BotAway::Spinner.spin id
  page.should have_css('label[for="%s"]' % id)
end

Then(/^the obfuscated label should not contain the text "(.*?)"$/) do |arg1|
  # TODO: if this fails, we should really check if the offending text
  # is actually within an obfuscated label.
  page.body.should_not match(arg1)
end

Given(/^note the "(.*?)" field$/) do |arg1|
  model_name, field_name = arg1.split ' '
  name = "#{model_name}[#{field_name}]"
  id = [ model_name, field_name ].join '_'

  @obfuscated_name = BotAway::Spinner.spin name
  @obfuscated_id = BotAway::Spinner.spin id
end

Then(/^the name of the "(.*?)" field should have changed$/) do |arg1|
  page.should_not have_css 'input[type=text][name="%s"]' %  @obfuscated_name
  step 'there should be an obfuscated text field for "%s"' % arg1
end

Then(/^the ID of the "(.*?)" field should have changed$/) do |arg1|
  page.should_not have_css 'input[type=text][id="%s"]' %  @obfuscated_id
  step 'there should be an obfuscated text field for "%s"' % arg1
end

Given(/^the "(.*?)" field is filled in$/) do |arg1|
  fill_in arg1, with: "text"
end
