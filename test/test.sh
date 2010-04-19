#!/bin/bash

newdata="./result"
expected="./expected"
data="./source"

test -d "$newdata" || mkdir -p "$newdata"
test -d "$expected" || mkdir -p "$expected"

# generate new reference data:

for i in ./testcases/*.orig; do
    vim -u NONE -N -S "$i" "$data";
    mv *.new "$expected"
done

for i in ./testcases/*.vim; do
    #vim -u NONE -N -S ~/.vim/plugin/Join.vim -S "$i" "$data";
    vim -u NONE -N -S "$PWD"/../plugin/Join.vim -S "$i" "$data";
    mv *.new "$newdata"
done

for i in "$newdata"/*.new; do
    j=`basename "$i"`
    if `diff "$i" "$expected"/"$j" >/dev/null`; then
	echo "Test $j passed!" 
    else
	echo "Test $j failed!"
    fi
done
