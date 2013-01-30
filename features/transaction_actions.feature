@javascript
Feature: Transaction Actions
  As a user
  I would like to approve/reject/hold a transaction

  Background:
    Given I have the following users with role
      | email                    | company_name | company_website     | role     |
      | admin1@riskychimp.com    | RiskyChimp   | www.riskychimp.com  | admin    |
    And I login with email "admin1@riskychimp.com" and password "secret"
    And I have the following transactions
      | transaction_id  | transaction_datetime              | amount |
      | 1               | Time.now.strftime('%Y/%m/%d')     | 10     |
    And I visit transactions page

  Scenario: Approve transaction
    When I click "Approve"
    Then I should see the transaction is approved
    And I should see the reviewer is "admin1@riskychimp.com"

  Scenario: Reject transaction
    When I click "Reject"
    Then I should see the transaction is rejected
    And I should see the reviewer is "admin1@riskychimp.com"

  Scenario: Hold transaction
    When I click "Hold"
    Then I should see the transaction is holding
    And I should see the reviewer is "admin1@riskychimp.com"

  Scenario: Reset transaction
    When I click "Approve"
    Then I should see the transaction is approved
    And I should see the reviewer is "admin1@riskychimp.com"
    And I click "Reset"
    Then I should see the transaction is pending
    And I should see the reviewer is ""
