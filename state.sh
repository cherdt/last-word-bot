#!/bin/bash

MYPATH=.

echo "State File"
echo "as of $(date)"
echo

MATCHRULES=$(ls match)

for MATCHRULE in $MATCHRULES
do
    echo "[$MATCHRULE] - match keywords/keyphrases"
    cat $MYPATH/match/$MATCHRULE
    echo
    echo "[$MATCHRULE] - replies"
    cat $MYPATH/replies/$MATCHRULE
    echo
    echo
done

echo "[DEFAULT] - replies"
cat replies.txt

echo
echo

echo "SCORE"
sort --reverse --numeric-sort --key=2 score
