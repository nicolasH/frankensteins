#!/bin/bash

if [ "$1" = "init" ];then
    echo "         init : Creates the blog directory and copies all the 'templates' files (_files) there."
    mkdir blog; ls _*-* | sed 's:_\(.*\):mv _\1 blog/\1:'| bash
    echo "You can now add the 'blog' directory to a git repository and save it.";exit
fi

if [ "$1" = "new" ];then
    echo "  new [title] : Creates an blog post at blog/`date +%Y_%m_%d`.[prettified title].md ."
    echo "$2" >> blog/`date +%Y_%m_%d.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md;exit
fi

if [ "$1" = "clean" ];then
    echo "        clean : Removes the generated html files by removing the date directories"
    cd blog; rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm index.html archives.html;exit
fi

if [ "$1" = "gen" ];then
    echo "          gen : Generates the blog"
    echo "0 - Removing the generated html files by removing the year directories"
    cd blog; rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm index.html archives.html
    echo "1 - Creating the year/month/day directories"
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#_#/#g'|sort | uniq`
    echo "2 - Creating the posts"
    ls *.md|sort -r| sed 's#\(.\{10\}\)\.\(.*\)\.md#echo \1 \1.\2.html >> titles;head -n 1 TK\1.\2.md|sed "s:\#\*::g" >> titles;cat both-header >> \1.\2.html;head -n 1 TK\1.\2.md |sed "s:\#\*::g" >> \1.\2.html;cat post-body >> \1.\2\.html;echo "<span class=\\"date\\">\1</span> <a href=\\"\2.html\\"> ">> \1.\2.html;multimarkdown TK\1.\2.md | sed "1 s:>$:></a>:" >> \1.\2\.html;cat both-footer >> \1.\2\.html;#' |sed 's#_#\/#g'|sed 's# TK\(....\)\/\(..\)\/\(..\)\.# \1_\2_\3.#g' | sed 's: \(....\/..\/..\)\.: \1\/:g'|bash
    echo "3 - Creating the blog home page"
    cat both-header index-body >> index.html
    ls *.md|sort -r|head -n 1|sed 's#\(....\).\(..\).\(..\).\(.*\).md#echo "<span class=\"date\">\1\/\2\/\3</span> <a href=\\"\1\/\2\/\3\/\4.html\\">";multimarkdown \1\_\2\_\3.\4.md|sed "1 s:>$:></a>:"#'|bash >> index.html
    cat index-middle >>index.html
    #Transform last 5 previous posts into the Date Link Title format.
    head -n 12 titles | sed -e :a -e '1,2d; /\(\.*\.html\)$/N; s/\n/\"\>/; ta' | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index_item\"\><span class=\"date\">\1</span> <span class=\"date_sep\"> \&raquo\;</span> <span class=\"title\"><a href\=\"\2\<\/a\></span>\<\/div\>:'>>index.html
    cat both-footer >> index.html
    echo "4 - Creating the blog archive page"
    cat both-header  >> archives.html
    cat archives-body >> archives.html
    #Transform all the lines of the titles file into the Date Link Title format.
    sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index_item\"\><span class=\"date\">\1</span> <span class=\"date_sep\"> \&raquo\;</span> <span class=\"title\"><a href\=\"\2\<\/a\></span>\<\/div\>:'>> archives.html
    cat both-footer >> archives.html;rm titles
    echo "And voila!";exit
fi
echo "usage : ___.sh init new [title] clean gen";cat ___.sh | grep "echo \" " |bash
