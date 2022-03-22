#!/bin/bash

# echo "TEST" > man/test.txt

for rst in rst/commands/*.rst
do
  NAME="${rst##*/}"
  NAME="${NAME%.rst}"
  # echo "$NAME"
  DAMN="${NAME##*_}"
  # echo "$DAMN"
  (awk 'BEGIN{tab=0} tab==1 && /^\t/ && /^\n/{tab=0} /^\.\./{getline; tab=1} tab==1&&/^\t/{gsub("^\t","",$0)}1 {tab==0}1' "$rst" | perl -0777 -pe 's/\n.*\n\nSYNOPSIS/\nSYNOPSIS/' | tail -n +2 ; echo) > man/"$NAME".rst
done