#!/bin/bash
# shared functions. this file is not mean to be called directly.

# twitter usernames can be up to 15 characters
# and contain only alphanumeric characters and underscores
# grep wants to us to escape the curly braces, but not here
USERNAME_REGEX='^[A-Za-z0-9_]{1,15}$'

is_line_in_file () {
    fgrep -i -x "$1" $2
}

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

is_social () {
    if [ -e $MYPATH/.social ]
    then
        return 0
    fi
    return 1
}

send_help_reply() {
    send_dm_reply "Commands: [ON|OFF|SOCIAL|UNSOCIAL|AUTH user|DEAUTH user|+ text|- text|URL]. https://github.com/cherdt/last-word-bot"
}

send_not_authorized() {
    send_dm_reply "I'm sorry Dave, I'm afraid I can't do that."
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

send_social_confirmation () {
    send_dm_reply "I am now in SOCIAL mode and will respond to tweets DM'd from any follower. Try UNSOCIAL to change modes"
}

send_unsocial_confirmation () {
    send_dm_reply "I am now in UNSOCIAL mode and will respond to tweets DM'd from authorized users only. Try SOCIAL to change modes"
}

is_authorized () {
    grep --quiet ^$SENDER$ $MYPATH/authorized_users
}

add_authorized_users () {
    USERS=$(echo $1 | sed 's/^\(AUTH\|\+@\?\)//')
    for USER in $USERS
    do
        USER=$(echo $USER | sed 's/\+\?@\?//')
        add_authorized_user $USER
    done
}

add_authorized_user () {
    if ! is_authorized
    then
        send_not_authorized
        return 1
    fi

    if [[ $1 =~ $USERNAME_REGEX ]]
    then
        # append username to auth users file
        echo "$1" >> $MYPATH/authorized_users
        send_dm_reply "New authorized user added: $1"
    else
        send_dm_reply "Invalid username: $1"
    fi
}

delete_authorized_users () {
    USERS=$(echo $1 | sed 's/^\(DEAUTH\|-@\?\)//')
    for USER in $USERS
    do
        delete_authorized_user $USER
    done
}

delete_authorized_user () {
    if is_authorized
    then
        USER=$(echo $1 | sed 's/-\?@\?//')
        # find and remove string from replies
        if is_line_in_file $USER $MYPATH/authorized_users 
        then
            sed -i "/^$USER$/Id" $MYPATH/authorized_users
            send_dm_reply "Removed authorized user: @$USER"
        else
            send_dm_reply "I did not find $USER in the current list of authorized users."
        fi
    else
        send_not_authorized
    fi
}
