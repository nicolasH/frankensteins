#!/bin/bash
echo 'My blog generating script : mostly commandline'
#create the year directories
#mkdir ` ls | cut -c 1-4 | sort | uniq `
#create year + month directories
#mkdir -p `ls -l | cut -c 46- | sed 's#\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*#\1/\2/#'|sort | uniq`

#dir with year, month , day 
DIRS=`ls -l blog/*.text| cut -c 46- | sed 's#\(blog\/[0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*#\1/\2/\3/#'|sort | uniq`

echo "mkdir -p $DIRS"
mkdir -p $DIRS

MMD=`ls -l *.text| cut -c 46- | sed 's#\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\.\(.*\)\.text#cat head_1 >> \1/\2/\3/\4\.html; head -n 1 \1\2\3\.\4.text >> \1/\2/\3/\4\.html;cat head_2 >> \1/\2/\3/\4\.html;  multimarkdown \1\2\3\.\4.text >> \1/\2/\3/\4\.html;cat footer >> \1/\2/\3/\4\.html;#'`
rm tmp.sh
echo "$MMD" >> tmp.sh
bash tmp.sh
rm tmp.sh

INDEX=`find 
echo $INDEX
#And voila!

