Feature: Honeypots
  
  Honeypots are invisible form elements that a human can't fill in. They are
  designed to fool automated agents into filling them in. If a honeypot has
  data entered into it, then whatever did the entering is probably not human.

  Scenario: a honeypot should be generated for the text field
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
    Then there should be a honeypot named "account[login]" with ID "account_login"

  Scenario: it should be possible to disable a honeypot
    Given it is 10:00:00 on 1/1/2013
      And the following view:
      """erb
        <%= form_for @account do |f| %>
          <%= f.label :login %>
          <%= f.text_field :login, honeypot: false %>
          <%= f.submit %>
        <% end %>
      """
    When the view is rendered
    Then there should not be a honeypot named "account[login]" with ID "account_login"
