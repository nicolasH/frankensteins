#!/bin/bash

if [ "$1" = "init" ]
then
    mkdir blog/
    cp index-header blog/
    cp index-body blog/
    cp index-footer blog/

    cp post-header blog/
    cp post-body blog/
    cp post-footer blog/

fi

if [ "$1" = "new" ]
then
    echo "creating an empty unamed blog post at blog/`date +%Y-%m-%d.%H%M`.md"
    cd blog
    touch `date +%Y_%m_%d.%H%M.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md
    echo $2 >> `date +%Y_%m_%d.%H%M.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md
    exit
fi

if [ "$1" = "clean" ]
then
    echo "Removing the generated html files"
    rm -r blog/2006 blog/2007 blog/2008 blog/2009 blog/2010 blog/2011
    rm blog/index.html
    exit
fi

if [ "$1" = "gen" ]
then
    echo "Removing the generated html files"
    rm -r blog/2006 blog/2007 blog/2008 blog/2009 blog/2010 blog/2011
    rm blog/index.html

    echo 'Generating the blog'
    echo '1 - Creating the directories'
    #create the year/month/day directories
    cd blog
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    echo 'Creating the posts'
#creates a command for each post that: create an html page from the head_1, the title (first line) of the post, the head_2, the multimarkdowned version of the post file and the footer. Also adds the url of the generated html file and the first line of the .md file to a 'titles' file in the blog directory.
    echo `ls *.md| sed 's#\(.\{10\}\)\(.*\)\.md#echo \1 \1\2.html >> titles;head -n 1 TK\1\2.md >> titles;cat post-header >> \1\2.html;head -n 1 TK\1\2.md >> \1\2.html;cat post-body >> \1\2\.html;multimarkdown TK\1\2.md >> \1\2\.html;cat post-footer >> \1\2\.html;#' |sed 's#_#\/#g'|sed 's# TK\(....\)\/\(..\)\/\(..\)\.# \1_\2_\3.#g' | sed 's: \(....\/..\/..\)\.: \1\/:g'` >> unlikelyNamedTmpFile.sh
    bash  unlikelyNamedTmpFile.sh
    rm unlikelyNamedTmpFile.sh

    rm index.html
    echo '2 - Creating the index'
    cat index-header >> index.html
    cat index-body >> index.html
    
#Transform the lines of the titles file into the Date Link Title format.
    `sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index\"\>\1 \&raquo\; <a href\=\"\2\<\/a\>\<\\div\>:'>>index.html`
    rm titles
    cat index-footer >> index.html
fi
echo "And voila!"
