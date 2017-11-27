#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

URLREGEX='https://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

source $MYPATH/shared.sh

debug () {
    if false
    then
        echo "$1"
    fi
}

get_tweet_info() {
    # Get the redirect/location info from the HTTP header
    TARGETTWEET=$(curl --silent --head $1 | grep 'location:')
    TARGETUSER=$(echo $TARGETTWEET | cut -d'/' -f 4)
    TWEETID=$(echo $TARGETTWEET | cut -d'/' -f 6)
}

# Message ID, sender, recipient, etc. are passed in by --exec
ID=$1
SENDER=$2
RECIPIENT=$3
TWEETTEXT=$4

# ignore DMs from unauthorized users, unless in social mode
if !(is_social || is_authorized)
then
    # exit quietly, as the bot owner may want to reply directly
    exit 0
fi

# Process command
process_command $TWEETTEXT

exit 0

