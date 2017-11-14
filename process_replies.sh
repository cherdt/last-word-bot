#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

# Pick one reply at random
REPLY=$(shuf -n 1 $MYPATH/replies.txt)

# Message ID and Username are passed in via --exec
MESSAGEID=$1
USERNAME=$2

# Reply to the tweet
twidge -c $CONFIG update --inreplyto $MESSAGEID "@$USERNAME $REPLY" 

# Write an entry to the message log
logger "sent reply to $USERNAME"
