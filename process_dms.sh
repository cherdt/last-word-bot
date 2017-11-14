#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

# Pick 1 reply at random
REPLY=$(shuf -n 1 $MYPATH/replies.txt)

# Message ID, sender, recipient, etc. are passed in by --exec
ID=$1
SENDER=$2
RECIPIENT=$3
TWEETTEXT=$4

# We are expecting to receive a DM with a shortened t.co link
# If we receive anything else, we should reply with an error
URLREGEX='https://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ $TWEETTEXT =~ $URLREGEX ]]
then
    # Get the redirect/location info from the HTTP header 
    TARGETTWEET=$(curl --silent --head $TWEETTEXT | grep 'location:')
    TARGETUSER=$(echo $TARGETTWEET | cut -d'/' -f 4)
    TWEETID=$(echo $TARGETTWEET | cut -d'/' -f 6)
 
    # write and entry to the message log 
    logger "Replying to $TARGETUSER with a random reply"
 
    # Reply to the message referenced by the DM
    twidge -c $CONFIG update --inreplyto $TWEETID "@$TARGETUSER $REPLY"
else
    logger "Failed to parse DM: $TWEETTEXT"
    twidge dmsend $SENDER "Sorry I didn't understand that"
    exit 1
fi

exit 0
