#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

source $MYPATH/shared.sh

# Message ID and Username are passed in via --exec
MESSAGEID=$1
USERNAME=$2

if is_enabled
then
    # Pick one reply at random
    REPLY=$(shuf -n 1 $MYPATH/replies.txt)

    # Reply to the tweet
    twidge -c $CONFIG update --inreplyto $MESSAGEID "@$USERNAME $REPLY" 
    
    # Write an entry to the message log
    logger "sent reply to $USERNAME"
fi

exit 0
