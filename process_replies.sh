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
    get_random_reply

    # Reply to the tweet
    twidge -c $CONFIG update --inreplyto $MESSAGEID "@$USERNAME $REPLY" 
    
    # Write an entry to the message log
    logger "sent reply to $USERNAME"
fi

exit 0
