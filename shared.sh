#!/bin/bash
# shared functions. this file is not mean to be called directly.

is_enabled () {
    if [ -e $MYPATH/.disabled ]
    then
	return 1
    fi
    return 0
}
