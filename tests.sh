#!/bin/bash

# An attempt to add some test cases

MYPATH=.
CONFIG=$MYPATH/.twidgerc

source shared.sh

# override DM replies for testing
send_dm_reply () {
    echo "[TEST] send_dm_reply: $1"
}

# override is_authorized while testing 
is_authorized () {
    true
}


process_command () {

if [[ $1 =~ ^[\+-]?~[0-9a-zA-Z]+\ [0-9a-zA-Z|#\ ]+$ ]]
then
    if [[ $1 =~ ^-~ ]]
    then
        echo "delete match"
        delete_rule_match $1
    else
        echo "add match"
        add_rule_match $1
    fi
elif [[ $1 =~ ^\+ ]]
then
    add_reply_string "$1"
elif [[ $1 =~ ^- ]]
then
    delete_reply_string "$1"
elif [[ $1 =~ ^LIST ]]
then
    send_rules_list
fi
}

# test adding match to example rule
TESTNAME="adding match to example rule"
process_command "+~10example testing"
if is_line_in_file "testing" $MYPATH/match/10example
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi

# test deleting match from example rule
TESTNAME="deleting match from example rule"
process_command "-~10example testing"
if ! is_line_in_file "testing" $MYPATH/match/10example
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi

# test adding reply to default rule
TESTNAME="adding reply to default rule"
process_command "+ default rule test"
if is_line_in_file "default rule test" $MYPATH/$DEFAULT
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi

# test adding reply to example rule
TESTNAME="adding reply to example rule"
process_command "+10example default rule test"
if is_line_in_file "default rule test" $MYPATH/replies/10example
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi



# test removing reply from default rule
TESTNAME="removing reply from default rule"
process_command "- default rule test"
if ! is_line_in_file "default rule test" $MYPATH/$DEFAULT
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi

# test removing reply from example rule
TESTNAME="removing reply from example rule"
process_command "-10example default rule test"
if ! is_line_in_file "default rule test" $MYPATH/replies/10example
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi

# test listing rules
TESTNAME="list match rules"
process_command "LIST RULES"

exit 0
