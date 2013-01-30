@javascript
Feature: Transactions
  As a user
  I would like to view my transactions

  Background:
    Given I login
    And I have the following transactions
      | transaction_id  | transaction_datetime              | amount |
      | 1               | Time.now.strftime('%Y/%m/%d')     | 10     |
      | 2               | 3.days.ago.strftime('%Y/%m/%d')   | 15     |
      | 3               | 10.days.ago.strftime('%Y/%m/%d')  | 5      |
    And I visit transactions page

  Scenario: Select 'Today'
    When I click "Today"
    Then I should see all transactions within today

  Scenario: Select '7 days'
    When I click "7 days"
    Then I should see all transactions within 7 days

  Scenario: Select 'All'
    When I click "All"
    Then I should see all transactions within the end of time

  Scenario: Change amount threshold
    When I change the amount threshold to '10'
    And I click "Update"
    Then I should see all transactions with amount above or equal '10'

  Scenario: Sort by 'Amount'
    When I click "Amount"
    Then I should see that the transactions are sorted by "amount" in "asc" order
    And I click "Amount"
    Then I should see that the transactions are sorted by "amount" in "desc" order

  Scenario: Take note
    When I click "Show Note"
    Then I should see note form
    And I input note field with "my first note"
    Then I click "Create Note"
    And I should see message "Note has been created"
    Then I click "Hide Note"
    And I should not see note form
    Then I click "Show Note"
    And I input note field with "my new note"
    Then I click "Update Note"
    And I should see message "Update successfully"