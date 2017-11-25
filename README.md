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
* In the repo, run `twidge setup`
* Open the twitter URL when prompted
* Enter the code at the twidge prompt
* Test it: `twidge update "I am a robot!"`
* Add your canned replies to `replies.txt`. They will be selected at (pseudo)random.
* Add cron entries as described in `CRONTAB.md`
* Optionally, add your personal twitter username to `authorized_users`

Commands
--------

You can interact with a configured bot via twitter direct messages (DMs) using the following commands:

* `(ON|ENABLE)` - re-enables the bot after it's been in an OFF state.
* `(OFF|DISABLE)` - disables the bot. You can still add and remove replies while the bot is in an OFF state.
* `(SOCIAL|EXTROVERT|ALLOW|[>)` - puts the bot in SOCIAL mode, in which it will reply to tweets sent via Direct Message by any follower.
* `(UNSOCIAL|INTROVERT|DENY|[<)` - puts the bot in the default UNSOCIAL mode, in which it will reply to tweets sent via Direct Message by authorized users only.
* `+reply text` - adds reply text to the list of random replies.
* `-reply text` - removes reply text from the list of random replies. Note that the text must be an exact match!
* `url` - the bot will try to follow the t.co link and add a random reply.
* `HELP` - lists commands, links to this page.

Disclaimers
-----------

* This is not all that well tested. If something doesn't work the way you expected, open an issue or submit a pull request. Who knows, maybe I'll even look at it.
* If this bot starts talking to another bot of the same design, they will probably talk to each other forever. This bot always wants to have the last word. Maybe this is your shot at immortality. Assuming twitter outlives you. Let's hope not.
