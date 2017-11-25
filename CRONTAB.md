Adding crontab entries
======================

Once you have twidge configured, edit your crontab (e.g. `crontab -e`) and add these entries:

```
*/5 * * * * ~/last-word-bot/follow_users.sh
* * * * * twidge -c ~/last-word-bot/.twidgerc lsdm --saveid --unseen --exec="~/last-word-bot/process_dms.sh"
* * * * * twidge -c ~/last-word-bot/.twidgerc lsreplies --saveid --unseen --exec="~/last-word-bot/process_replies.sh"
```
