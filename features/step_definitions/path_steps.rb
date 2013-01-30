Given /^I visit (.*?) page$/ do |path|
  case path
    when 'sign up' then visit(new_user_registration_path)
    when 'sign in' then visit(new_user_session_path)
    when 'refinery' then visit('/refinery')
    else visit(eval("#{path}_path"))
  end
end