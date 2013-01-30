@javascript
Feature: User role
  As a product owner
  I would like that only admin can access refinery admin section

  Scenario: Admin access refinery admin section
    When I login as "admin"
    And I visit refinery page
    Then I should see refinery page content

  Scenario: Normal user access refinery admin section
    When I login
    And I visit refinery page
    Then I should be on home page
