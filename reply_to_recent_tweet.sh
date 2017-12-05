#!/bin/bash

# This script searches the Twitter API for recent tweets matching a keyword
# and then passes information about that tweet to process_replies.sh

TOKEN=""
KEYWORD=$(shuf --echo -n 1 myfirsttweet bored)

# Search twitter for a recent tweet containing the selected keyword
JSON=$(curl --silent --get 'https://api.twitter.com/1.1/search/tweets.json' --data "&q=$KEYWORD&count=1" -H "Authorization: Bearer $TOKEN")

# Note that retweets contain information about the tweet, as well as the 
# parent tweet (i.e. the tweet that is being retweeted). We need to reply
# to the parent tweet in order for Twitter to display it properly in context.

# Parse the returned JSON and select only the elements we need
# This step is unnecessary but makes it easier to read when debugging
SHORTJSON=$(echo $JSON | jq '{tweetid: .statuses[0].id_str, text: .statuses[0].text, screen_name: .statuses[0].user.screen_name, rt_id: .statuses[0].retweeted_status.id_str, rt_screen_name: .statuses[0].retweeted_status.user.screen_name }')

# Extract JSON fields and save to variables
MESSAGEID=$(echo $SHORTJSON | jq '.tweetid' | tr --delete '"')
USERNAME=$(echo $SHORTJSON | jq '.screen_name' | tr --delete '"')
TWEET=$(echo $SHORTJSON | jq '.text')
RT_ID=$(echo $SHORTJSON | jq '.rt_id' | tr --delete '"')
RT_USERNAME=$(echo $SHORTJSON | jq '.rt_screen_name' | tr --delete '"')

# Pass data as arguments to process_replies.sh
if [ "$USERNAME" = "null" ]
then
    # something went wrong, do nothing
    :
else
    if [ "$RT_ID" != "null" ]
    then
        ./process_replies.sh "$RT_ID" $USERNAME "null" "$TWEET"
    else
        ./process_replies.sh "$MESSAGEID" $USERNAME "null" "$TWEET"
    fi
fi

exit 0
