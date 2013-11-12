Given(/^the following view:$/) do |string|
  path_to_view = Rails.root.join "app/views/accounts/new.html.erb"
  FileUtils.mkdir_p File.dirname(path_to_view)
  File.open path_to_view, 'w' do |f|
    f.print string
  end
end

When(/^the view is rendered$/) do
  visit '/accounts/new'
end

When(/^the form is submitted$/) do
  click_button "Create Account"
end

When(/^the form is sumitted without any hashed fields$/) do
  len = BotAway::Spinner::SALT_LENGTH + BotAway::Spinner::HASH_LENGTH
  page.all("input[type=text]").each do |ele|
    if ele.native['id'] =~ /\A[a-f0-9]{#{len},#{len}}\z/
      ele.native.remove
    end
  end

  step 'the form is submitted'
end
