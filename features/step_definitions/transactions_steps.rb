Given /^I have the following transactions$/ do |transaction_table|
  transaction_table.hashes.each do |hash|
    hash['transaction_datetime'] = eval(hash['transaction_datetime'])
    FactoryGirl.create(:transaction, hash.merge(user: @user))
  end
end

Then /^I should see all transactions within (.*?)$/ do |type|
  case type
    when "today" then
      all("table//tr").length.should == 3
    when "7 days" then
      all("table//tr").length.should == 5
    else
      all("table//tr").length.should == 7
  end
end

Then /^I should see the transaction is (.*?)$/ do |status|
  if status == 'pending'
    find(:xpath , "//td[@class='transaction-actions']").text.should include('Approve')
    find(:xpath , "//td[@class='transaction-actions']").text.should include('Reject')
    find(:xpath , "//td[@class='transaction-actions']").text.should include('Hold')
  else
    find(:xpath , "//td[@class='transaction-actions']").text.should include(status.capitalize)
  end
end

Then /^I should see the reviewer is "(.*?)"$/ do |email|
  find(:xpath, "//td[@class='reviewer']").text.should == email
end

When /^I change the amount threshold to '(\d+)'$/ do |value|
  fill_in 'user_setting_amount_threshold', with: value
end

Then /^I should see that the transactions are sorted by "(.*?)" in "(.*?)" order$/ do |value, order|
  transactions = Transaction.order("#{value} #{order}")
  index = 2
  transactions.each do |transaction|
    find(:xpath , "//table//tr[#{index}]/td[1]").text.should == "#{transaction.id}"
    index += 2
  end
end

Then /^I should see all transactions with amount above or equal '(.*?)'$/ do |amount_threshold|
  all("table//tr").length.should == 5
end

Then /^I should see note form$/ do
  find(:xpath , "//textarea[@id='note_content']").should be_visible
end

Then /^I should not see note form$/ do
  find(:xpath , "//textarea[@id='note_content']").should_not be_visible
end

