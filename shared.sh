#!/bin/bash
# shared functions. this file is not mean to be called directly.

# twitter usernames can be up to 15 characters
# and contain only alphanumeric characters and underscores
# grep wants to us to escape the curly braces, but not here
USERNAME_REGEX='^[A-Za-z0-9_]{1,15}$'

# DEFAULT replies
DEFAULT=replies.txt

is_line_in_file () {
    fgrep --quiet -i -x "$1" $2
}

does_rule_match_tweet () {
    fgrep -i --word-regexp --file=$MYPATH/match/$1 <(echo $2)
}

get_random_reply () {
    # pick 1 reply at random
    REPLY=$(shuf -n 1 ${1-$DEFAULT})
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

send_syntax_error () {
    send_dm_reply "Sorry, I didn't undertand that. Try HELP"
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

# test a command to see if it is a valid match rule
is_valid_match_rule () {
    echo $1 | grep --quiet "^[-+~]~\?[0-9a-zA-Z]\+[[:space:]]\+.\+"
}

# append the specified line to the specified file 
add_line_to_file () {
    # Add the line only if it is not already present
    if ! $(grep --quiet -i "^$1$" "$2")
    then
        echo "$1" >> $2
    fi
}


# process match rules (add match strings to, remove match strings from, a rule)
process_match_rule () {
#    if is_valid_match_rule "$1"
#    then
        RULENAME=$(get_rule_name "$1")
        RULEPATH=$(get_rule_path "$1")
        # TODO rename this function? 
        process () {
            if [[ $1 =~ ^-~? ]]
            then
                delete_line_from_file "$2" "$3"
            else
                add_line_to_file "$2" "$3"
            fi
        }

        process_reply_string () {
            if [[ $1 =~ ^(.~|~) ]]
            then
                for KEYWORD in $(get_reply_text "$1")
                do
                    process "$1" "$KEYWORD" "$RULEPATH"
                done
            else
                REPLY_TEXT=$(get_reply_text "$1")
                process "$1" "$REPLY_TEXT" "$RULEPATH"
            fi
        }

        process_reply_string "$1"
#    else
#        send_syntax_error
#    fi
}


# remove a lines matching the specified string from the specified file
delete_line_from_file () {
    sed -i "/^$1$/Id" $2
}

# remove match keywords for a specified rule
delete_rule_match () {
    echo "stub"
}

# returns true (0) if the specified reply already exists in the rule file
is_existing_reply () {
    echo "stub"
}

# does the command include a reply rule
# TODO this is poorly named, rules can apply to matches and replies
is_reply_rule_specified () {
    echo "$1" | grep --quiet "^[-+~]~\?[0-9a-zA-Z]"
}

# adds the specified reply string to a replies file
add_reply_string () {
    echo "stub"
}

# get the rule name from a command
get_rule_name () {
    if is_reply_rule_specified "$1"
    then
        # rules are preceded by +, -, ~, +~, or -~
        echo "$1" | cut -d' ' -f 1 | sed 's/^[-\+~]~\?//'
    else
        echo "default replies"
    fi
}

# get the rule path based on the rule name
get_rule_path () {
    RULENAME=$(get_rule_name "$1")

    if [ "$RULENAME" = "default replies" ]
    then
        echo "$MYPATH/$DEFAULT"
    else
        # determine if this is for a match keyword or a reply
        if [[ $1 =~ ^[-\+]?~ ]]
        then
            MYDIR=match
        else
            MYDIR=replies
        fi
        echo "$MYPATH/$MYDIR/$RULENAME"
    fi
}

# get the reply text from a command
get_reply_text () {
    echo $1 | cut -d' ' -f 2-
}

# delete the specified reply string from a replies file
delete_reply_string () {
    echo "stub"
}

# send list of rule names
send_rules_list () {
    send_dm_reply $(ls $MYPATH/match/)
}

# Process command
process_command () {
    if [[ $1 =~ ^(ON|ENABLE)$ && is_authorized ]]
    then
        rm $MYPATH/.disabled
        send_on_confirmation
    elif [[ $1 =~ ^(AUTH|\+@) && is_authorized ]]
    then
        add_authorized_users "$1"
    elif [[ $1 =~ ^(DEAUTH|-@) && is_authorized ]]
    then
        delete_authorized_users "$1"
    elif [[ $1 =~ ^(OFF|DISABLE)$ && is_authorized ]]
    then
        touch $MYPATH/.disabled
        send_off_confirmation
    elif [[ $1 =~ ^(SOCIAL|EXTROVERT|\[>|ALLOW)$ && is_authorized ]]
    then
        touch $MYPATH/.social
        send_social_confirmation
    elif [[ $1 =~ ^(UNSOCIAL|INTROVERT|\[<|DENY)$ && is_authorized ]]
    then
        rm $MYPATH/.social
        send_unsocial_confirmation
    # if DM begins with LIST then we are listing match rules
    elif [[ $1 =~ ^LIST && is_authorized ]]
    then
        send_rules_list
    # if DM begins with "+~, -~, or ~" then we are modifying a match rule 
    elif [[ $1 =~ ^[-~\+]~? && is_authorized ]]
    then
        process_match_rule "$1"
    # if DM begins with "+" then we are adding a reply string
    elif [[ $1 =~ ^\+ && is_authorized ]]
    then
        add_reply_string "$1"
    # if DM begins with "-" then we are deleting a reply string
    elif [[ $1 =~ ^- && is_authorized ]]
    then
        delete_reply_string "$1"
    elif [[ $1 =~ ^HELP ]]
    then
        send_help_reply
    # check for URL, likely a shortened twitter link
    elif [[ $1 =~ $URLREGEX ]]
    then
        if is_enabled
        then
            get_tweet_info "$1"
    
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
        logger "Failed to parse DM: $1"
        send_syntax_error
    fi
}

