Feature: Middleware
  
  The server-side of BotAway checks for submitted data and tries to validate
  that it did not come from an automated source. It does this by checking
  that honeypots are not filled in, that form data is submitted within an
  expected timeframe, and that the original form was not tampered with.

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
      And the view is rendered

  Scenario: Missing hashed fields indicates a tampered-with form
    When the form is sumitted without any hashed fields
    Then a bot should be detected

  Scenario: Filled in honeypot indicates a bot
    Given the "account login" honeypot is filled in
    When the form is submitted
    Then a bot should be detected

  Scenario: Blank honeypots and proper time window indicates a human
    Given the "Login" field is filled in
      And it is 10:01:00 on 1/1/2013
    When the form is submitted
    Then a bot should not be detected

  # When a request payload is received a very short time after the view was
  # generated, it may indicate an automated response.
  Scenario: Short time indicates a bot
    Given the "Login" field is filled in
    When the form is submitted
    Then a bot should be detected

  # When a request payload is received a very long time after the view was
  # generated, it may indicate a replayed form. It could have been recorded
  # by a human user, and then fed into a bot to be replayed many times.
  Scenario: Long time indicates a bot
    Given the "Login" field is filled in
      And it is 20:00:00 on 1/1/2013
    When the form is submitted
    Then a bot should be detected
