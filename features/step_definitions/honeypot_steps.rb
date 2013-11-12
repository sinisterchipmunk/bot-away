Then(/^there should( not)? be a honeypot named "(.*?)" with ID "(.*?)"$/) do |is_not, arg1, arg2|
  if is_not.blank?
    page.should have_css('input[name="%s"][id="%s"]' % [arg1, arg2], visible: false)
  else
    page.should_not have_css('input[name="%s"][id="%s"]' % [arg1, arg2], visible: false)
  end
end

Then(/^there should be a text field named "(.*?)" with ID "(.*?)"$/) do |arg1, arg2|
  page.should have_css('input[type=text][name="%s"][id="%s"]' % [arg1, arg2])
end

Given(/^the "(.*?)" honeypot is filled in$/) do |arg1|
  model_name, field_name = *arg1.split(' ')
  id = [ model_name, field_name ].join '_'
  page.find("##{id}", visible: false).set 'text'
end
