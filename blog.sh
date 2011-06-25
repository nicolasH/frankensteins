#!/bin/bash


if [ "$1" = "new" ]
then
    echo "creating an empty unamed blog post at blog/`date +%Y%m%d.%H%M`.text" 
    touch blog/`date +%Y%m%d.%H%M`.text
    exit
fi

echo 'Creating the directories'
#create the year/month/day directories
mkdir -p `ls -l blog/*.text| cut -c 46- | sed 's#\(blog\/[0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*#\1/\2/\3/#'|sort | uniq`

echo 'Creating the posts'
#creates a command for each post that: create an html page from the head_1, the title (first line) of the post, the head_2, the multimarkdowned version of the post file and the footer. Also adds the url of the generated html file and the first line of the .text file to a 'titles' file in the blog directory.
echo `ls -l blog/*.text| cut -c 46- | sed 's#\(blog\/[0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\.\(.*\)\.text#echo \1/\2/\3/ \1/\2/\3/\4\.html >> titles;head -n 1 \1\2\3\.\4.text >> titles;cat header >> \1/\2/\3/\4\.html;head -n 1 \1\2\3\.\4.text >> \1/\2/\3/\4\.html;cat blog/body >> \1/\2/\3/\4\.html;multimarkdown \1\2\3\.\4.text >> \1/\2/\3/\4\.html;cat footer >> \1/\2/\3/\4\.html;#'`>> tmp.sh
bash tmp.sh
rm tmp.sh

echo 'Creating the index'
cat header >> blog/index.html
echo "Blog for Niconomicon" >> blog/index.html
cat body >> blog/index.html
#Transform the lines of the titles file into the Date Link Title format.
`sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(blog\/\)\(.\{12\}\)\.*blog\/\(.*\):\<div class=\"index\"\>\2<a href\=\"\3\<\/a\>\<\\div\>:'>>blog/index.html`
rm titles
cat footer >> blog/index.html

echo "And voila!"

