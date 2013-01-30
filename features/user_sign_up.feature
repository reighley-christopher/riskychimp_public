@javascript
Feature: User sign up
  As an visitor
  I would like to sign up

  Background:
    Given I visit sign up page

  Scenario: Sign up unsuccessful because of not agree with terms of use
    When I input email field with "riskychimp.test@gmail.com"
    And I input password field with "123456"
    And I input password confirmation field with "123456"
    And I click "Sign up" button
    Then I should not sign up successfully
    And I should see message "Terms must be accepted"

  Scenario: Sign up and receive confirmation email
    When I input email field with "riskychimp.test@gmail.com"
    And I input password field with "123456"
    And I input password confirmation field with "123456"
    And I agree with the terms of use
    And I click "Sign up" button
    Then I should receive an email sent to "riskychimp.test@gmail.com" with subject "Confirmation instructions"
    And I follow link "Confirm my account" in the email "Confirmation instructions" sent to "riskychimp.test@gmail.com"
    Then I should sign up successfully
