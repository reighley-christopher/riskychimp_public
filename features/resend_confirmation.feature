@javascript
Feature: Resend confirmation
  Background:
    Given I signed up with email "test@gmail.com" and password "secret"
    And I have not confirmed the email "test@gmail.com"
    And I visit sign up page
    And I click "Didn't receive confirmation instructions?"

  Scenario: With valid email
    Then I should see message "Resend confirmation instructions"
    And I input email field with "test@gmail.com" in "resend confirmation" form
    And I click "Resend"
    Then I should receive an email sent to "test@gmail.com" with subject "Confirmation instructions"

  Scenario: With invalid email
    And I input email field with "test1@gmail.com" in "resend confirmation" form
    And I click "Resend"
    Then I should see message "Email not found"

  Scenario: With no email
    And I click "Resend"
    Then I should see message "Email can't be blank"
