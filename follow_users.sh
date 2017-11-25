#!/bin/bash

# Define the location of the twidgerc file
CONFIG=.twidgerc
MYPATH=.

logger "starting $MYPATH/follow_users.sh"

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
    twidge -c $MYPATH/$CONFIG dmsend $USER "Thanks for the follow! If you see any lively debate on twitter, loop me in by DMing me a tweet."
done < $MYPATH/users_to_follow

exit 0
