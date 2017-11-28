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


# test is valid match rule 
TESTNAME="is valid match rule"
TESTVAL1="~10example sample template exhibit" 
TESTVAL2="+~10example sample template exhibit"
TESTVAL3="-~10example sample template exhibit"
TESTVAL4="+~ wrong wrong wrong"
if is_valid_match_rule "$TESTVAL1" && \
   is_valid_match_rule "$TESTVAL2" && \
   is_valid_match_rule "$TESTVAL3" && \
   ! is_valid_match_rule "$TESTVAL4"
then
   echo "PASS: $TESTNAME"
else
   echo "FAIL: $TESTNAME"
fi


# test reply rule detection
TESTNAME="detect reply rule presence"
TESTVAL1="+ No reply rule here"
TESTVAL2="- No reply rule here"
TESTVAL3="+sample Yes here is a reply rule"
TESTVAL4="-sample Yes here is a reply rule"
TESTVAL5="~sample Yes here is a match rule"
TESTVAL6="+~sample Yes here is a match rule"
TESTVAL7="-~sample Yes here is a match rule"
if ! is_reply_rule_specified $TESTVAL1 && \
   ! is_reply_rule_specified $TESTVAL2 && \
   is_reply_rule_specified $TESTVAL3 && \
   is_reply_rule_specified $TESTVAL4 && \
   is_reply_rule_specified $TESTVAL5 && \
   is_reply_rule_specified $TESTVAL6 && \
   is_reply_rule_specified $TESTVAL7
then
   echo "PASS: $TESTNAME"
else
   echo "FAIL: $TESTNAME"
fi
    
 
# test extracting rule name from a command
TESTNAME="extract rule name from a command"
EXPECTED1="99sample"
EXPECTED2="default replies"
TESTVAL1=$(get_rule_name "+99sample sample reply text")
TESTVAL2=$(get_rule_name "-99sample sample reply text")
TESTVAL3=$(get_rule_name "+~99sample sample example demo")
TESTVAL4=$(get_rule_name "~99sample sample example demo")
TESTVAL5=$(get_rule_name "-~99sample sample example demo")
TESTVAL6=$(get_rule_name "+ sample reply text")
TESTVAL7=$(get_rule_name "- sample reply text")
if [[ "$EXPECTED1" = "$TESTVAL1" && \
      "$EXPECTED1" = "$TESTVAL2" && \
      "$EXPECTED1" = "$TESTVAL3" && \
      "$EXPECTED1" = "$TESTVAL4" && \
      "$EXPECTED1" = "$TESTVAL5" && \
      "$EXPECTED2" = "$TESTVAL6" && \
      "$EXPECTED2" = "$TESTVAL7" ]]
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi


# test extracting reply text from a command
TESTNAME="extract reply text from a command"
EXPECTED="sample reply text"
TESTVAL1=$(get_reply_text "+ sample reply text")
TESTVAL2=$(get_reply_text "- sample reply text")
TESTVAL3=$(get_reply_text "+10example sample reply text")
TESTVAL4=$(get_reply_text "-10example sample reply text")
if [[ "$EXPECTED" = "$TESTVAL1" && "$EXPECTED" = "$TESTVAL2" && "$EXPECTED" = "$TESTVAL3" && "$EXPECTED" = "$TESTVAL4" ]] 
then
    echo "PASS: $TESTNAME"
else
    echo "FAIL: $TESTNAME"
fi


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
