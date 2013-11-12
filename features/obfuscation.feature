Feature: Obfuscation
  
  An important feature of BotAway is field obfuscation. The names and IDs
  of form elements are obfuscated during view generation by generating hashes
  of their proper values (including some extra, secret data to keep them from
  being predictable). The real names and IDs become Honeypots, while the
  obfuscated names and IDs are used for legitimate data entry. This way, a
  bot can't possibly determine an email from a first name or phone number.
  It just has to guess. Thus, even if the bot manages to detect the nature of
  Honeypots, the chance that it'll be able to pass your model validations is
  quite low.

  Label elements are also hashed, so that they point correctly to their
  corresponding input elements. The content of a label element is obfuscated
  in other ways, such that a human can still read the label but a bot would
  have to be relatively sophisticated to do so.

  Background:
    Given it is 10:00:00 on 1/1/2013
      And the following view:
      """erb
        <%= form_for @account do |f| %>
          <%= f.label :login %>
          <%= f.text_field :login %>
          <%= f.submit %>
        <% end %>
      """
    When the view is rendered

  Scenario: real input fields should be obfuscated
    Then there should be an obfuscated text field for "account login"

  Scenario: Names and IDs of real input fields should change based on the time
    Given note the "account login" field
      And it is 10:10:00 on 1/1/2013
    When the view is rendered
    Then the name of the "account login" field should have changed
      And the ID of the "account login" field should have changed

  Scenario: labels should be linked to real elements
    Then there should be an obfuscated label for "account login"
      And the obfuscated label should not contain the text "Login"
    But I should see "Login"
