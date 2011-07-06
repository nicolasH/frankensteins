#!/bin/bash

if [ "$1" = "init" ];then
    echo "        init : Creates the blog directory and copies all the 'templates' files (_files) there."
    mkdir blog; ls _*-* | sed 's:_\(.*\):mv _\1 blog/\1:'| bash
    echo "You can now add the 'blog' directory to a git repository and save it."
    exit
fi

if [ "$1" = "new" ];then
    echo " new [title] : Creates an blog post at blog/`date +%Y_%m_%d`.[prettified title].md ."
    echo "$2" >> blog/`date +%Y_%m_%d.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md
    exit
fi

if [ "$1" = "clean" ];then
    cd blog
    echo "       clean : Removes the generated html files by removing the date directories"
    rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm index.html
    exit
fi

if [ "$1" = "gen" ];then
    echo "         gen : Generates the blog"
    cd blog
    echo "0 - Removing the generated html files by removing the year directories"
    rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm index.html
    echo "1 - Creating the year/month/day directories"
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    echo "2 - Creating the posts"
    ls *.md|sort -r| sed 's#\(.\{10\}\)\(.*\)\.md#echo \1 \1\2.html >> titles;head -n 1 TK\1\2.md|sed "s:\#\*::g" >> titles;cat post-header >> \1\2.html;head -n 1 TK\1\2.md |sed "s:\#\*::g" >> \1\2.html;cat post-body >> \1\2\.html;echo "<div class=\"date\">\1</div>">> \1\2.html;multimarkdown TK\1\2.md >> \1\2\.html;cat post-footer >> \1\2\.html;#' |sed 's#_#\/#g'|sed 's# TK\(....\)\/\(..\)\/\(..\)\.# \1_\2_\3.#g' | sed 's: \(....\/..\/..\)\.: \1\/:g'|bash
    echo "3 - Creating the index"
    cat index-header index-body >> index.html
    ls *.md|sort -r|head -n 1|sed 's#\(....\).\(..\).\(..\)\(.*\)#echo "<div class=\"date\">\1\/\2\/\3</div>";multimarkdown \1\_\2\_\3\4;#'|bash >> index.html
    cat index-middle >>index.html
    #Transform the lines of the titles file into the Date Link Title format.
    sed -e :a -e '1,2d; /\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index_item\"\>\1 \&raquo\; <a href\=\"\2\<\/a\>\<\/div\>:'>>index.html
    cat index-footer >> index.html;rm titles
    echo "And voila!"
    exit
fi
echo "usage : ___.sh init new [title] clean gen";cat ___.sh | grep "echo \" " |bash
