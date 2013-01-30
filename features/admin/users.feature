@javascript
Feature: Admin manage users
  Background:
    Given I have the following users with role
      | email                    | company_name | company_website     | role     |
      | merchant1@riskychimp.com | Merchant A   | www.merchant_a.com  | merchant |
      | merchant2@riskychimp.com | Merchant B   | www.merchant_b.com  | merchant |
      | admin1@riskychimp.com    | RiskyChimp   | www.riskychimp.com  | admin    |
      | admin2@riskychimp.com    | RiskyChimp   | www.riskychimp.com  | admin    |
    And I login with email "admin1@riskychimp.com" and password "secret"

  Scenario: Admin can see the list of users based on role
    When I visit admin_users page
    And I should see the following users
      | email                    | company_name | company_website     |
      | merchant1@riskychimp.com | Merchant A   | www.merchant_a.com  |
      | merchant2@riskychimp.com | Merchant B   | www.merchant_b.com  |
    And I should not see the following users
      | email                    | company_name | company_website     |
      | admin1@riskychimp.com    | RiskyChimp   | www.riskychimp.com  |
      | admin2@riskychimp.com    | RiskyChimp   | www.riskychimp.com  |
    Then I click "Admins"
    And I should not see the following users
      | email                    | company_name | company_website     |
      | merchant1@riskychimp.com | Merchant A   | www.merchant_a.com  |
      | merchant2@riskychimp.com | Merchant B   | www.merchant_b.com  |
    And I should see the following users
      | email                    | company_name | company_website     |
      | admin1@riskychimp.com    | RiskyChimp   | www.riskychimp.com  |
      | admin2@riskychimp.com    | RiskyChimp   | www.riskychimp.com  |

  Scenario: Admin can invite new merchant
    When I visit admin_users page
    And I click "Create Merchant"
    And I input email field with "new_user@test.com"
    And I click "Send Invitation Email"
    Then I should receive an email sent to "new_user@test.com" with subject "Invitation instructions"
    And I logout
    And I follow link "Accept Invitation" in the email "Invitation instructions" sent to "new_user@test.com"
    And I input password field with "secret"
    And I input password confirmation field with "secret"
    And I click "Set my password"
    Then I should sign in successfully
    And I should have role "merchant"

  Scenario: Admin can change a merchant to reviewer
    When I visit admin_users page
    And I click "merchant1@riskychimp.com"
    And I click "Edit"
    And I select value "reviewer" from "user_role"
    And I select value "merchant2@riskychimp.com" from "user_merchant_id"
    And I click "Update" button
    And I visit admin_users page
    Then I should not see "merchant1@riskychimp.com"
    And I click "merchant2@riskychimp.com"
    And I click "Manage Reviewers"
    Then I should see "merchant1@riskychimp.com"

  Scenario: Admin can change a reviewer to merchant
    When I visit admin_users page
    And I click "merchant1@riskychimp.com"
    And I click "Edit"
    And I select value "reviewer" from "user_role"
    And I select value "merchant2@riskychimp.com" from "user_merchant_id"
    And I click "Update" button
    And I visit admin_users page
    And I click "merchant2@riskychimp.com"
    And I click "Manage Reviewers"
    And I click "Edit"
    And I select value "merchant" from "user_role"
    And I click "Update" button
    And I visit admin_users page
    Then I should see "merchant1@riskychimp.com"
    And I click "merchant2@riskychimp.com"
    And I click "Manage Reviewers"
    Then I should not see "merchant1@riskychimp.com"


  Scenario: Admin can login as merchant
    When I visit admin_users page
    And I click "merchant1@riskychimp.com"
    And I click "Login as user"
    Then I should sign in successfully with email "merchant1@riskychimp.com"

  Scenario: Admin can manage reviewers of a merchant
    When I visit admin_users page
    And I click "merchant1@riskychimp.com"
    And I click "Manage Reviewers"
    Then I click "Create Reviewer"
    And I input email field with "reviewer1@riskychimp.com"
    And I click "Send Invitation Email"
    Then I should see message "Invitation email has been sent successfully."
    And I should see message "reviewer1@riskychimp.com"
    And I click "Login as user"
    Then I should see message "You have to confirm your account before continuing."
    And I follow link "Accept Invitation" in the email "Invitation instructions" sent to "reviewer1@riskychimp.com"
    And I input password field with "secret"
    And I input password confirmation field with "secret"
    And I click "Set my password"
    Then I should sign in successfully
    And I should have role "reviewer"
    And I logout
    Then I login with email "admin1@riskychimp.com" and password "secret"
    And I visit admin_users page
    And I click "merchant1@riskychimp.com"
    And I click "Manage Reviewers"
    And I click "Login as user"
    Then I should sign in successfully with email "reviewer1@riskychimp.com"
    And I logout
    Then I login with email "merchant1@riskychimp.com" and password "secret"
    And I click "Manage Reviewers"
    Then I should see message "reviewer1@riskychimp.com"
    And I should not see message "Login as user"

  Scenario: Invite wrong email and user report error
    When I visit admin_users page
    And I click "Create Merchant"
    And I input email field with "wrong_email@test.com"
    And I click "Send Invitation Email"
    Then I should receive an email sent to "wrong_email@test.com" with subject "Invitation instructions"
    And I follow link "please let us know!" in the email "Invitation instructions" sent to "wrong_email@test.com"
    Then I should see message "We have received your report. Thank you."
    Then I visit admin_users page
    And I click "Error"
    Then I should see the following users
      | email                    | company_name | company_website |
      | wrong_email@test.com     |              |                 |
