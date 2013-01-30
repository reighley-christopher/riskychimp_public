@javascript
Feature: Reset password
  Background:
    Given I signed up with email "test@gmail.com" and password "secret"
    And I visit sign in page
    And I click "Forgot password?"
  
  Scenario: With valid email
    Then I should see message "Forgot your password?"
    And I input email field with "test@gmail.com" in "forgot password" form
    And I click "Send"
    Then I should receive an email sent to "test@gmail.com" with subject "Reset password instructions"
    And I follow link "Change my password" in the email "Reset password instructions" sent to "test@gmail.com"
    Then I input New password field with "new_secret"
    And I input Confirm new password field with "new_secret"
    And I click "Change"
    Then I should sign in successfully
    
  Scenario: With invalid email
    And I input email field with "test1@gmail.com" in "forgot password" form
    And I click "Send"
    Then I should see message "Email not found"

  Scenario: With no email
    And I click "Send"
    Then I should see message "Email can't be blank"
