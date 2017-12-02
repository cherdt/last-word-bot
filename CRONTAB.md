Adding crontab entries
======================

Once you have twidge configured, edit your crontab (e.g. `crontab -e`) and add these entries:

```
# Check for new followers every 5 minutes and follow them back
*/5 * * * * cd ~/last-word-bot && ./follow_users.sh

# Check for and process new direct messages every minute
* * * * * cd ~/last-word-bot && twidge -c .twidgerc lsdm --saveid --unseen --exec="$(pwd)/process_dms.sh"

# Check for and process new replies every minute
* * * * * cd ~/last-word-bot && twidge -c .twidgerc lsreplies --saveid --unseen --exec="$(pwd)/process_replies.sh"
```
