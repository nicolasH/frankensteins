#!/bin/bash

if [ "$1" = "init" ]
then
    mkdir blog
    #cp `ls _* | sed 's:_\(.*\):\1 blog/\1:'`
    cp _index-header blog/index-header
    cp _index-body blog/index-body
    cp _index-footer blog/index-footer

    cp _post-header blog/post-header
    cp _post-body blog/post-body
    cp _post-footer blog/post-footer

    cp _css.css blog/css.css

fi

if [ "$1" = "new" ]
then
    echo "creating an empty unamed blog post at blog/`date +%Y-%m-%d.%H%M`.md"
    cd blog
    touch `date +%Y_%m_%d.%H%M.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md
    echo $2 >> `date +%Y_%m_%d.%H%M.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md
    echo "You can now add the blog directory to a git repository and save it."
    exit
fi

if [ "$1" = "clean" ]
then
    echo "Removing the generated html files"
    cd blog
    rm -r `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    rm index.html
    exit
fi

if [ "$1" = "gen" ]
then
    echo "0 - Removing the generated html files"
    cd blog
    rm -r `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    rm index.html

    echo 'Generating the blog'
    echo '1 - Creating the directories'
    #create the year/month/day directories
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    echo '2 - Creating the posts'
#creates a command for each post that: create an html page from the head_1, the title (first line) of the post, the head_2, the multimarkdowned version of the post file and the footer. Also adds the url of the generated html file and the first line of the .md file to a 'titles' file in the blog directory.
    echo `ls *.md| sed 's#\(.\{10\}\)\(.*\)\.md#echo \1 \1\2.html >> titles;head -n 1 TK\1\2.md >> titles;cat post-header >> \1\2.html;head -n 1 TK\1\2.md >> \1\2.html;cat post-body >> \1\2\.html;multimarkdown TK\1\2.md >> \1\2\.html;cat post-footer >> \1\2\.html;#' |sed 's#_#\/#g'|sed 's# TK\(....\)\/\(..\)\/\(..\)\.# \1_\2_\3.#g' | sed 's: \(....\/..\/..\)\.: \1\/:g'` >> unlikelyNamedTmpFile.sh
    bash  unlikelyNamedTmpFile.sh
    rm unlikelyNamedTmpFile.sh

    rm index.html
    echo '3 - Creating the index'
    cat index-header >> index.html
    cat index-body >> index.html
    
#Transform the lines of the titles file into the Date Link Title format.
    `sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index\"\>\1 \&raquo\; <a href\=\"\2\<\/a\>\<\\div\>:'>>index.html`
    rm titles
    cat index-footer >> index.html
    
fi
echo "And voila!"

    
