When /^I agree with the terms of use$/ do
  check "user_terms"
end

When /^I click "(.*?)"$/ do |link|
  click_on link
end

When /^I click "(.*?)" button$/ do |button|
  click_button button
end

Then /^I should sign up successfully$/ do
  page.should have_selector("li#sign-out-btn")
end

Then /^I should not sign up successfully$/ do
  page.should have_selector("li#sign-in-btn")
end

Then /^I (should|should not) see message "(.*?)"$/ do |should_or_not, message|
  page.send(should_or_not.gsub(" ", '_'), have_content(message))
end

Given /^I login$/ do
  @user = FactoryGirl.create(:user, :password => 'secret')
  visit('/users/sign_in')
  fill_in "Email", :with => @user.email
  fill_in "Password", :with => 'secret'
  click_button 'Sign in'
end

When /^I login as "(.*?)"$/ do |role|
  @user = FactoryGirl.create(:user, password: 'secret', role: role)
  visit('/users/sign_in')
  fill_in "Email", :with => @user.email
  fill_in "Password", :with => 'secret'
  click_button 'Sign in'
end

Given /^I login with email "(.*?)" and password "(.*?)"$/ do |email, password|
  visit('/users/sign_in')
  fill_in "Email", :with => email
  fill_in "Password", :with => password
  click_button 'Sign in'
end

Given /^I logout$/ do
  page.find("#sign-out-btn a").click
end

Then /^I should see refinery page content$/ do
  page.should have_content("Switch to your website")
  page.should have_content("Quick Tasks")
end

Then /^I should be on home page$/ do
  current_path.should == '/'
end

When /^I input (.*?) field with "(.*?)"$/ do |field, value|
  fill_in "#{field.camelize}", :with => value
end

Then /^I should receive an email sent to "(.*?)" with subject "(.*?)"$/ do |email_address, email_subject|
  ActionMailer::Base.deliveries.select{|email| email.to.include?(email_address) && email.subject == email_subject}.should_not be_blank
end

Then /^I follow link "(.*?)" in the email "(.*?)" sent to "(.*?)"$/ do |link_title, email_subject, email_address|
  email = ActionMailer::Base.deliveries.select{|email| email.to.include?(email_address) && email.subject == email_subject}.last
  email_body = "<root>#{email.body}</root>"

  REXML::Document.new(email_body).get_elements("//a").each do |link|
    if link.text == link_title
      visit link.attribute("href").value
      break
    end
  end
end

Given /^I signed up with email "(.*?)" and password "(.*?)"$/ do |email, password|
  FactoryGirl.create(:user, email: email, password: password)
end

Then /^I should sign in successfully$/ do
  within("#credential-container") do
    page.should have_content("Hi,")
  end
end

Then /^I should sign in successfully with email "(.*?)"$/ do |email|
  within("#credential-container") do
    page.should have_content("Hi, #{email}")
  end
end

Given /^I input (.*?) field with "(.*?)" in "(.*?)" form$/ do |field, value, container|
  within("##{container.downcase.parameterize}") do
    fill_in "#{field.camelize}", :with => value
  end
end

Given /^I have not confirmed the email "(.*?)"$/ do |email|
  if user = User.find_by_email(email)
    user.update_attribute(:confirmed_at, nil)
  end
end

Given /^I have the following users with role$/ do |user_table|
  user_table.hashes.each do |hash|
    role = hash.delete('role')
    user = FactoryGirl.create(:user, hash)
    user.add_role(role)
  end
end

When /^I (should|should not) see the following users$/ do |should_or_not, user_table|
  user_table.hashes.each do |hash|
    within("#body-container table#users") do
      hash.each do |key, value|
        page.send(should_or_not.gsub(" ", '_'), have_content(value))
      end
    end
  end
end

Then /^I should have role "(.*?)"$/ do |role|
  current_user_email = page.find("#credential-container #user-box a").text.split("Hi,").last.strip
  current_user = User.where(email: current_user_email).first
  current_user && current_user.has_role?(role)
end

When /^I select value "(.*?)" from "(.*?)"$/ do |value, select_box|
  select(value, :from => select_box)
end

Then /^I (should|should not) see "(.*?)"$/ do |should_or_not, user|
  page.send(should_or_not.gsub(" ", '_'), have_content(user))
end
