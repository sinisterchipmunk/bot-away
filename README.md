# bot-away [![Build Status](https://secure.travis-ci.org/sinisterchipmunk/bot-away.png)](http://travis-ci.org/sinisterchipmunk/bot-away)

* http://github.com/sinisterchipmunk/bot-away

Unobtrusively detects form submissions made by spambots, and silently drops those submissions. The key word here is
"unobtrusive" -- this is NOT a CAPTCHA. This is a transparent, modular implementation of the bot-catching techniques
discussed by Ned Batchelder at http://nedbatchelder.com/text/stopbots.html.

## How It Works

If a bot submission is detected, the params hash is cleared, so the data can't be used. Since this includes the
authenticity token, Rails should complain about an invalid or missing authenticity token. Congrats, spam blocked.

The specifics of the techniques employed for filtering spambots are discussed Ned's site in the description; however,
here's a brief run-down of what's going on:

* Your code stays the same. After the Bot-Away gem has been activated, all Rails-generated forms on your site
  will automatically be transformed into bot-resistent forms.
* All of the form elements that you create (for instance, a "comment" model with a "body" field) are turned into
  dummy elements, or honeypots, and are made invisible to the end user. This is done using div elements and inline 
  CSS stylesheets (I decided against a JavaScript option because it's the most likely to be disabled on a legitimate
  client). There are several ways an element can be hidden, and these approaches are chosen at random to help
  minimize predictability.
  * In the rare event that a real user actually can see the element, it has a label next to it
    along the lines of "Leave this blank" -- though the exact message is randomized to help prevent detection by
    bots.
* All of the form elements are mirrored by hashes. The hashes are generated using the session's authenticity token,
  so they can't be predicted.
* When data is submitted, Bot-Away steps in and
  1. validates that no honeypots have been filled in; and
  2. converts the hashed elements back into the field names that you are expecting (replacing the honeypot fields).
     Your code is never aware of the difference; it's just business as usual as long as the user is legitimate.
* If a honeypot has been filled in, or a hashed element is missing where it was expected, then the request is
  considered to be either spam, or tampered with; and the entire params hash is emptied. Since this happens at the
  lowest level, the most likely result is that Rails will complain that the user's authenticity token is invalid. If
  that does not happen, then your code will be passed a params hash containing only a "suspected_bot" key, and an
  error will result. Either way, the spambot has been foiled!

## Installation:

* gem install bot-away

## Usage:

Whether you're on Rails 2 or Rails 3, adding Bot-Away to your project is as easy as telling Rails where to find it.

### Rails 2.x

The Rails 2.x version will still receive bug fixes, but is no longer under active development. To use bot-away with Rails 2, pull in bot-away v1.x:

    # in config/environment.rb:
    config.gem 'bot-away', '~> 1.2'

### Rails 3

    # in Gemfile
    gem 'bot-away', '~> 2.0'

That's it.

## Whitelists

Sometimes you don't care about whether or not a bot is filling out a particular form. Even more, sometimes it's
preferable to make a form bot-friendly. I'm talking specifically about login forms, where all sorts of people
use bots (their Web browsers, usually) in order to prefill the form with their login information. This is perfectly
harmless, and even a malicious bot is not going to be able to cause any trouble on a form like this because it'll only be denied access to the site.

In cases like these, you'll want to go ahead and disable Bot-Away. Since Bot-Away is only disabled on a per-controller or per-action basis, it stays active throughout the remainder of your site, which prevents bots from (for example) creating new users.

To disable Bot-Away for an entire controller, add this line to a file called `config/initializers/bot-away.rb`:

    BotAway.disabled_for :controller => 'sessions'
  
And here's how to do the same for a specific action, leaving Bot-Away active for all other actions:

    BotAway.disabled_for :controller => 'sessions', :action => 'login'
  
You can also disable Bot-Away for a given action in every controller, but I'm not sure how useful that is. In any case, here's how to do it:

    BotAway.disabled_for :action => 'index' # all we did was omit :controller
  
This line can be specified multiple times, for each of the controllers and/or actions that you need it disabled for.
  
## Disabling Bot-Away in Development

If, while developing your app, you find yourself viewing the HTML source code, it'll probably be more helpful
to have Bot-Away disabled entirely so that you're not confused by MD5 tags and legions of honeypots. This is easy enough to do:

    BotAway.disabled_for :mode => 'development'
    
## Accepting Unfiltered Params

Sometimes you need to tell Bot-Away to explicitly _not_ filter a parameter. This is most notable with fields you've
dynamically added via JavaScript, since those can confuse Bot-Away's catching techniques. (It tends to think Javascript-
generated fields are honeypots, and raises an error based on that.) Here's how to tell Bot-Away that such fields are
not to be checked:

    BotAway.accepts_unfiltered_params "name_of_param", "name_of_another_param"

Note that these parameters can be either model keys, field keys or exact matches. For example, imagine the following
scenario: you have two models, `User` and `Group`, and each `has_many :roles`. That means you'll likely have an administration screen somewhere with check boxes representing user roles and group roles. Here are the different ways you can control how Bot-Away interacts with these fields:

    BotAway.accepts_unfiltered_params "user"
      # disables BotAway filtering for ALL fields belonging to 'user', but NO fields belonging to 'group'

    BotAway.accepts_unfiltered_params 'user[role_ids]', 'group[role_ids]'
      # disables BotAway filtering for ONLY the 'role_ids' field belonging to BOTH 'user' and 'group', while leaving
      # filtering enabled for ALL OTHER fields.

    BotAway.accepts_unfiltered_params 'role_ids'
      # disables BotAway filtering for ONLY the 'role_ids' fields belonging to ALL MODELS, while leaving all
      # other fields enabled.

You can specify this option as many times as you need to do.

## I18n

BotAway is mostly code, and produces mostly code, so there's not that much to translate. However, as mentioned above, the honeypots could theoretically be seen by humans in some rare cases (if they have an exceedingly simplistic browser or have disabled such fundamental Web controls as CSS). In these rare cases, BotAway prefixes the honeypot fields with a message akin to "Leave This Field Empty".

To further confound smart bots, these messages are chosen at random and by default there are 3 such messages BotAway can choose from. However, BotAway only supports the English language by default, so if you are targeting other languages you'll want to add translations. Also, to give your Web app a bit of personalization (highly recommended, if you want to keep the bot-builders guessing!) then you'll want to override and/or add to the English messages as well!

To do this, create a file in `config/locales/bot-away.yml` and add content such as this:

    en:
      bot_away:
        number_of_honeypot_warning_messages: 3
        honeypot_warning_1: "Leave this empty: "
        honeypot_warning_2: "Don't fill this in: "
        honeypot_warning_3: "Keep this blank: "

Shown above is exactly what resides in the default BotAway locale. Change the contents of warning strings 1 through 3 within your own app to override them; change the `number_of_honeypot_warning_messages` field to cause BotAway to choose randomly from more or fewer messages. Also, as the above example implies, you can set a different number of randomized warnings per language.

* If you'd like to add some warning messages to BotAway in currently-unsupported languages (or if you just want
  BotAway to have more messages to choose from) then your additions are welcome! Please fork this project,
  update the
  [lib/locale/honeypots.yml](https://github.com/sinisterchipmunk/bot-away/blob/master/lib/locale/honeypots.yml)
  file with your changes, and then send me a pull request!

* Honeypot warning messages are obfuscated: they are sent as reversed, unicode-escaped strings displayed within
  right-to-left directional tags (which are standard in HTML 4 and should be recognized by all browsers), so that in
  the unlikely event a bot can figure out what your I18n locale's "don't fill this in" text means, it'll also have to
  figure out how to read the text in reverse after unescaping the unicode characters. Obviously, human users won't
  have this problem.
  * To disable obfuscation of the honeypot warning messages (that is, serve them as plain left-to-right text), add 
    the line `BotAway.obfuscate_honeypot_warning_messages = false` to `config/initializers/bot-away.rb`.


## Further Configuration (Mostly for Debugging):

In general, Bot-Away doesn't have that much to configure. Most options only exist for your debugging pleasure, in
case something isn't quite working as you'd expected. As shown above, these settings should be specified in a file
called `config/initializers/bot-away.rb`. Configuration options available to you are as follows:

### Showing the Honeypots

Generally, you want to keep honeypots hidden, because they will clutter your interface and confuse your users. However, there was an issue awhile back (near the 1.0 release of Bot-Away) where Safari was a bit smarter than its competitors, successfully prefilling honeypots with data where Chrome, FF and IE all failed to do so. Eventually, I added the ability to show honeypots on the screen, proving my suspicion that Safari was being "too smart". After resolving the issue, I decided to leave this option available to Bot-Away as a debugging tool for handling future issues. To enable:
    
    BotAway.show_honeypots = true

### Dumping Params

Like showing honeypots, above, this option is only useful if you're debugging issues in development
mode. You can enable this if you need to see exactly what Rails sees _before_ Bot-Away steps in to intervene. Enabling this is a major security risk in production mode because it'll include sensitive data such as passwords; but it's very useful for debugging false positives (that is, Bot-Away thinks you're a bot, but you're not).

    BotAway.dump_params = true
  
## Features / Problems:

* Wherever protection from forgery is not enabled in your Rails app, the Rails forms will be generated as if this gem
  did not exist. That means hashed elements won't be generated, honeypots won't be generated, and posted forms will
  not be intercepted.

* By default, protection from forgery is enabled for all Rails controllers, so by default the above-mentioned checks
  will also be triggered. For more details on forgery protection, see:
  http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  
* The techniques implemented by this library will be very difficult for a spambot to circumvent. However, keep in
  mind that since the pages have to be machine-readable by definition, and since this gem has to follow certain
  protocols in order to avoid confusing lots of humans (such as hiding the honeypots), it is always theoretically
  possible for a spambot to get around it. It's just very, very difficult.

* I feel this library has been fairly well-tested (99.21% test coverage as of this writing), but if you discover a
  bug and can't be bothered to let me know about it (or you just don't have time to wait for a fix or fix it 
  yourself), then you can simply add the name of the offending form element to the BotAway.unfiltered_params
  array like so:
      BotAway.accepts_unfiltered_params 'role_ids'
      BotAway.accepts_unfiltered_params 'user' # this can be called multiple times
  You should also take note that this is an array, not a hash. So if you have a `user[role_ids]` as well as a
  `group[role_ids]`, the `role_ids` will not be filtered on EITHER of these models.

* Currently, there's no direct support for per-request configuration of unfiltered params. This is mostly due to
  Bot-Away's low-level approach to filtering bots: the params have already been filtered by the time your controller
  is created. I'd like to revisit per-request filtering sometime in the future, once I figure out the best way to do
  it.

## Requirements:

* Rails 3.0 or better.
