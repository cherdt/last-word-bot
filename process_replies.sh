#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

source $MYPATH/shared.sh

# Message ID and Username are passed in via --exec
MESSAGEID=$1
USERNAME=$2
TWEET=$4

if is_enabled
then
    get_random_reply
    for MATCHRULE in $(ls $MYPATH/match)
    do
        if does_rule_match_tweet $MATCHRULE "$TWEET" 
        then
            get_random_reply "$MYPATH/replies/$MATCHRULE"
            break
        fi
    done

    # Reply to the tweet
    if [ "$TESTVAL" != "" ]
    then
        twidge -c $CONFIG update --inreplyto $MESSAGEID "@$USERNAME $REPLY" 
    
        # Write an entry to the message log
        logger "sent reply to $USERNAME"
    fi
fi

exit 0
