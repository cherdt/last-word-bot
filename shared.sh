#!/bin/bash
# shared functions. this file is not mean to be called directly.

get_random_reply () {
    # pick 1 reply at random
    REPLY=$(shuf -n 1 $MYPATH/replies.txt)
}

is_enabled () {
    if [ -e $MYPATH/.disabled ]
    then
	return 1
    fi
    return 0
}

send_dm_reply () {
    twidge -c $MYPATH/$CONFIG dmsend $SENDER "$1"
}

send_off_confirmation () {
    send_dm_reply "I am now OFF. An authorized user can turn me on by sending the ON command"
}

send_on_confirmation () {
    send_dm_reply "I am now ON. An authorized user can turn me off by sending the OFF command"
}
