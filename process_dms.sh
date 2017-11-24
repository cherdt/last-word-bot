#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

URLREGEX='https://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

is_authorized () {
    grep ^$SENDER$ $MYPATH/authorized_users
}

add_reply_string() {
    if is_authorized
    then
        # append string to replies
        NEW_REPLY=$(echo "$TWEETTEXT" | sed -e 's/^\+[[:space:]]*//')
        echo "$NEW_REPLY" >> $MYPATH/replies.txt
        send_reply "New reply added: $NEW_REPLY"
    else
        send_reply "I'm sorry Dave, I'm afraid I can't do that."
    fi
}

send_reply() {
    twidge -c $MYPATH/$CONFIG dmsend $SENDER "$1"
}

send_help_reply() {
    send_reply "See https://github.com/cherdt/last-word-bot"
}

get_tweet_info() {
    # Get the redirect/location info from the HTTP header
    TARGETTWEET=$(curl --silent --head $1 | grep 'location:')
    TARGETUSER=$(echo $TARGETTWEET | cut -d'/' -f 4)
    TWEETID=$(echo $TARGETTWEET | cut -d'/' -f 6)
}

get_random_reply() {
    # Pick 1 reply at random
    REPLY=$(shuf -n 1 $MYPATH/replies.txt)
}

# Message ID, sender, recipient, etc. are passed in by --exec
ID=$1
SENDER=$2
RECIPIENT=$3
TWEETTEXT=$4

# Process command
# if DM begins with "+" then we are adding a reply string
if [[ $TWEETTEXT =~ ^\+ ]]
then
    add_reply_string 
# test for HELP command
elif [[ $TWEETTEXT =~ ^HELP ]]
then
    send_help_reply
# check for URL, likely a shortened twitter link
elif [[ $TWEETTEXT =~ $URLREGEX ]]
then
    get_tweet_info $TWEETTEXT

    # write and entry to the message log
    logger "Replying to $TARGETUSER with a random reply"

    # get random reply
    get_random_reply

    # Reply to the message referenced by the DM
    twidge -c $MYPATH/$CONFIG update --inreplyto $TWEETID "@$TARGETUSER $REPLY"
# otherwise, we didn't understand the command
else
    logger "Failed to parse DM: $TWEETTEXT"
    send_reply "Sorry, I didn't undertand that. Try HELP" 
fi

exit 0
