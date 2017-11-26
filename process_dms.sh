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

is_existing_reply () {
    grep "^$1$" $MYPATH/replies.txt
}

send_not_authorized() {
    send_dm_reply "I'm sorry Dave, I'm afraid I can't do that."
}

add_reply_string() {
    if is_authorized
    then
        # append string to replies
        NEW_REPLY=$(echo "$TWEETTEXT" | sed -e 's/^\+[[:space:]]*//')
        echo "$NEW_REPLY" >> $MYPATH/replies.txt
        send_dm_reply "New reply added: $NEW_REPLY"
    else
        send_not_authorized
    fi
}

delete_reply_string() {
    if is_authorized
    then
        # find and remove string from replies
	TARGET_REPLY=$(echo "$TWEETTEXT" | sed 's/^-[[:space:]]*//')
	if is_existing_reply "$TARGET_REPLY"
	then
	    sed -i "/^$TARGET_REPLY$/d" $MYPATH/replies.txt
	    send_dm_reply "Reply removed: $TARGET_REPLY"
	else
            send_dm_reply "I did not find that text in the current list of replies."
        fi
    else
        send_not_authorized
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

# Process commands
if [[ $TWEETTEXT =~ ^(ON|ENABLE)$ && is_authorized ]]
then
    rm $MYPATH/.disabled
    send_on_confirmation
elif [[ $TWEETTEXT =~ ^(AUTH|\+@) && is_authorized ]]
then
    add_authorized_users "$TWEETTEXT"
elif [[ $TWEETTEXT =~ ^(DEAUTH|-@) && is_authorized ]]
then
    delete_authorized_users "$TWEETTEXT"
elif [[ $TWEETTEXT =~ ^(OFF|DISABLE)$ && is_authorized ]]
then
    touch $MYPATH/.disabled
    send_off_confirmation
elif [[ $TWEETTEXT =~ ^(SOCIAL|EXTROVERT|\[>|ALLOW)$ && is_authorized ]]
then
    touch $MYPATH/.social
    send_social_confirmation
elif [[ $TWEETTEXT =~ ^(UNSOCIAL|INTROVERT|\[<|DENY)$ && is_authorized ]]
then
    rm $MYPATH/.social
    send_unsocial_confirmation
# if DM begins with "+" then we are adding a reply string
elif [[ $TWEETTEXT =~ ^\+ ]]
then
    add_reply_string 
# if DM begins with "-" then we are deleting a reply string
elif [[ $TWEETTEXT =~ ^- ]]
then
    delete_reply_string
elif [[ $TWEETTEXT =~ ^HELP ]]
then
    send_help_reply
# check for URL, likely a shortened twitter link
elif [[ $TWEETTEXT =~ $URLREGEX ]]
then
    if is_enabled
    then
	get_tweet_info $TWEETTEXT
    
        # write and entry to the message log
        logger "Replying to $TARGETUSER with a random reply"
    
        # get random reply
        get_random_reply
    
        # Reply to the message referenced by the DM
        twidge -c $MYPATH/$CONFIG update --inreplyto $TWEETID "@$TARGETUSER $REPLY"
    else
        send_dm_reply "I'm currently turned off. To turn me back on, an authorized user needs to send an ON command."
    fi

# otherwise, we didn't understand the command
else
    logger "Failed to parse DM: $TWEETTEXT"
    send_dm_reply "Sorry, I didn't undertand that. Try HELP" 
fi

exit 0
