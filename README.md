Last Word Bot
=============

Arguing with a nincompoop on Twitter can be exhausting. Why not relax and have a bot deal your ripostes while you do something more enjoyable?

You can log in as this bot and reply to your adversary directly. Any mention of your bot's @username should then trigger an automated reply. Alternatively, you can send a tweet as a Direct Message (DM) to the bot, and the bot will reply to that tweet.

In order for the latter to work, the bot needs to follow your account first. The follow_users.sh script will cause the bot to automatically follow any user that follows it. That may or may not be desirable. 


Dependencies
------------

Last Word Bot is cobbled together from Twidge + Bash + Cron. If you know Bash and Cron, this should be easy.

* Twidge. Twidge may be available in your Debian distro (`apt-get install twidge`), otherwise you can download and install it.
* Bash.
* Cron.


Setup
-----

* You'll need a twitter account. You can use a personal account, but I'd create a separate one if I were you.
* Clone this repo
  - Update MYPATH to use the full path in `follow_users.sh`, `process_dms.sh`, and `process_replies.sh`
  - Update the paths in `CRONTAB.md` to use the full path
* In the repo, run `twidge -c ./.twidgerc setup`
* Open the twitter URL when prompted
* Enter the code at the twidge prompt
* Test it: `twidge update "I am a robot!"`
* Add your canned replies to `replies.txt`. They will be selected at (pseudo)random.
* Add optional match rules to `match/rulename`. (Recommended: add a numeric 2-digit prefix to the rulename, so that it is easier to control the order of processing. E.g. `10example` will be processed before `20sample`.)
* Add optional match rule replies to `replies\rulename`. They will be selected at (pseudo)random when an incoming tweet/reply contains a word in the corresponding match rule.
* Add cron entries as described in `CRONTAB.md`
* Optionally, add the bot's username and/or your personal twitter username to `authorized_users`


Commands
--------

Authorized users can interact with a configured bot via twitter direct messages (DMs) using the following commands:

* `(ON|ENABLE)` - re-enables the bot after it's been in an OFF state.
* `(OFF|DISABLE)` - disables the bot. You can still add and remove replies while the bot is in an OFF state.
* `(SOCIAL|EXTROVERT|ALLOW|[>)` - puts the bot in SOCIAL mode, in which it will reply to tweets forwarded via Direct Message by *any*  follower.
* `(UNSOCIAL|INTROVERT|DENY|[<)` - puts the bot in the default UNSOCIAL mode, in which it will reply to tweets forwarded via Direct Message by authorized users only.
* `(AUTH|+@) username1 username2 ...` - add authorized users.
* `(DEAUTH|-@) username1 username2 ...` - remove authorized users.
* `+~rulename keyword {keyword}` - adds keywords to a match rule. (Keywords match *any* word in a tweet -- no multi-word phrases at this time.)
* `-~rulename keyword {keyword}` - removes keywords from a match rule.
* `+[rulename] reply text` - adds reply text to the list of random replies for `[rulename]`, or to the default replies if `[rulename]` is specified.
* `-[rulename] reply text` - removes reply text from the list of random replies for `[rulename]`, or from the default replies if `[rulename]` is not specified. Note that the text must be an exact match!
* `url` - the bot will try to follow the t.co link and add a random reply.
* `SCORE` - lists the total number of (public) replies to your bot.
* `TOP` - lists the user with the most replies to your bot, with the number of replies.
* `HELP` - lists commands, links to this page.


Other Features
--------------

### Madlibs-style replies

You can include madlibs-style word/phrase substitutions in replies, which pull from lists in the `madlibs` directory. For example, in the following reply:

`This is an <example> of a madlibs-style reply.`

`<example>` could be replaced by example, demonstration, illustration, or any other term in the `madlibs/example` file. The substitution lists can only be created and updated on the backend at this time, and cannot be updated via the twitter interface.


### Search for, and reply to, tweets

**WARNING** this is a little complicated if you haven't done it before. It's a little complicated even if you have done it before.

You'll need an API token and an API key. You'll need to use a twitter account with an attached phone number (it doesn't have to be your bot account). Go to https://apps.twitter.com and create a new app. The values below are just suggestions, you can use anything you want.

* Name: twitter-api-search
* Description: retrieve twitter search results via the API
* Website: https://github.com/cherdt/last-word-bot
* Callback URL: [leave blank]

It should provide you a Consumer Key (API Key) and Consumer Secret (API Secret). Using these 2 values you can create an Access Token:

`echo -n $API_KEY:$API_SECRET | base64 -w 0`

Assign the resulting gibberish text to the `TOKEN` variable at the top of `reply_to_recent_tweet.sh`

In the example, the search looks for tweets matching `KEYWORD`, which is a random selection of either 'myfirsttweet' or bored'. You can change these values as you like.


Limitations
-----------

* Twidge still thinks twitter is limited to 140 characters. This limits the length of your replies.
* Keyword match rules match on single words.


Disclaimers
-----------

* This is not all that well tested. If something doesn't work the way you expected, open an issue or submit a pull request. Who knows, maybe I'll even look at it.
* If this bot starts talking to another bot of the same design, they will probably talk to each other forever. This bot always wants to have the last word. Maybe this is your shot at immortality. Assuming twitter outlives you. Let's hope not.
