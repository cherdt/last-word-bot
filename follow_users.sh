#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

# Define DM response to new followers
DM_RESPONSE="Thanks for the follow! If you see any lively debate on twitter, loop me in by DMing me a tweet."

# Include shared functions
source $MYPATH/shared.sh

logger "starting $MYPATH/follow_users.sh"

# Ensure that the files that track users exist
for USERFILE in users_i_follow users_to_follow users_who_follow_me
do 
    touch -a $MYPATH/$USERFILE
done

# get users who recently followed me
twidge -c $MYPATH/$CONFIG lsfollowers > $MYPATH/users_who_follow_me
if [ $? -ne 0 ]
then
    logger "failed to get users who follow me"
    exit 1
fi

# users that follow me that I don't follow
comm -23 <(sort $MYPATH/users_who_follow_me | uniq) <(sort $MYPATH/users_i_follow | uniq) > $MYPATH/users_to_follow 

# follow users who follow me but I don't yet follow 
while read USER
do
    logger "following $USER and sending an intro DM"
    echo $USER >> $MYPATH/users_i_follow
    twidge -c $MYPATH/$CONFIG follow $USER
    send_dm "$USER" "$DM_RESPONSE"
done < $MYPATH/users_to_follow

exit 0
