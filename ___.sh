#!/bin/bash
if [ "$1" = "init" ];then
    echo "         init : Creates the content directory and copies all the 'templates' files (_files.html) there."
    mkdir -p content/blog content/notes content/projects; cp _*.html _*.xml _*.css content/
    echo "You can now add the 'content' directory to a git repository and save it.";exit
fi

if [ "$1" = "new" ];then
    echo "  new [title] : Creates a blog post at blog/[current_date].[prettified title].md ."
    echo "$2" >> content/blog/`date +%Y-%m-%d.%H%M.``echo $2 |sed 's:[\ \" \, \.\:\?\!_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md;exit
fi

if [ "$1" = "clean" ];then
    echo "        clean : Removes the generated html files by removing the date directories"
    cd content/blog; rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm titles index.html archives.html;exit
fi

if [ "$1" = "gen" ];then
    echo "          gen : Generates the blog"
    echo "0 - Removing the generated html files by removing the year directories"
    cd content/blog
    rm -r `ls *.md | cut -c 1-4 | sort | uniq`;rm index.html archives.html
    echo "1 - Creating the year/month/day directories"
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#\-#/#g'|sort | uniq`
    echo "2 - Creating the posts"
    ls *.md|sort -r| sed -E 's!(....)-(..)-(..).(.*).md!echo \1/\2/\3 \1/\2/\3/\4.html >> titles;head -n 1 & |tr -d "#" >> titles;cat ../_header.html >> \1/\2/\3/\4.html;head -n 1 & |tr -d "#" >> \1/\2/\3/\4.html;sed "s%blog nohl%blog highlighted%" ../_nav.html >> \1/\2/\3/\4.html;echo "<span class=\\"date\\">\1/\2/\3</span>  <span class=\\"date_sep\\"> \&raquo\;</span> <span class=\\"title\\"><a href=\\"/blog/\1/\2/\3/\4.html\\"> ">> \1/\2/\3/\4.html;multimarkdown & | sed "1 s:>$:></a></span>:" >> \1/\2/\3/\4.html;cat ../_footer.html >> \1/\2/\3/\4.html;!' | bash
    echo "3 - Creating _most_ of the blog home page"
    #cat ../_header.html ../_blog-nav.html >> index.html
    # Adding the latest post to the index page:
    ls *.md|sort -r|head -n 1|sed -E 's#(....)-(..)-(..).(.*).md#echo "<span class=\\"date\\">\1\/\2\/\3</span> <span class=\\"date_sep\\"> \&raquo\;</span> <span class=\\"title\\"> <a href=\\"/blog/\1\/\2\/\3\/\4.html\\">";multimarkdown &|sed "1 s:>$:></a></span>:"#'|bash >> index-blog.html
    #cat ../_home-middle.html >>index-blog.html
    # Add the 5 previous posts titles+link to the bottom of the index page:
    head -n 12 titles | sed -e :a -e '1,2d; /\(\.*\.html\)$/N; s/\n/\"\>/; ta' | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\\"index_item\\"\><span class=\\"date\">\1</span> <span class=\\"date_sep\\"> \&raquo\;</span> <span class=\\"title\\"><a href\=\"/blog/\2\<\/a\></span>\<\/div\>:'>>index-blog.html
    #cat ../_footer.html >> index.html
    echo "4 - Creating the blog archive page"
    cat ../_header.html >> archives.html;sed "s%blog nohl%blog highlighted%" ../_nav.html >> archives.html
    #Transform all the lines of the titles file into the Date Link Title format.
    sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles | sed 's:\(.\{11\}\)\.*\(.*\):\<div class=\"index_item\"\><span class=\"date\">\1</span> <span class=\"date_sep\"> \&raquo\;</span> <span class=\"title\"><a href\=\"\2\<\/a\></span>\<\/div\>:'>> archives.html
    cat ../_footer.html >> archives.html
    echo "5 - Creating the blog feed.xml"; cat ../_feed-top.xml > feed.xml
    echo "<updated>`date '+%Y/%m/%d %H:%M:%S'`</updated>">> feed.xml;echo "<rights>Copyright © `date '+%Y'`">> feed.xml;finger `whoami`| head -n 1 | sed -E "s|.*Name:(.*)$|\1|">>feed.xml; echo "</rights>" >> feed.xml
    ls *.md|sort -r| sed -E 's@(....)-(..)-(..).(.*).md@echo "<item><title>">> feed.xml; head -n 1 & |tr -d "#" >> feed.xml;echo "</title><link>/blog/\1/\2/\3/\4.html</link><pubDate>">>feed.xml;echo "\1/\2/\3 ">> feed.xml ; date -r `stat -f "%m" &` "+%H:%M:%S" >>feed.xml;echo "</pubDate><content:encoded><![CDATA[">> feed.xml;sed -e "1d" &|multimarkdown >> feed.xml;echo "]]></content:encoded></item>">>feed.xml@' | bash
    echo "</channel></rss>" >> feed.xml;rm titles
    cd ../../
    #echo "And voila!";exit

    ### Projects

    # blurbs into [language].txt
    # [language].txt into index.txt
    # cat ../projects.html > index.html
    # multimarkdown index.txt >> index.html
    # cat ../footer.html >> index.html
    #
    # for each project
    #   cat projects.html > index.html
    #   echo "[project]" > index.html
    #   cat top.html > index.html
    #   multimarkdown [project].txt >> index.html
    #   cat footer.html > index.html
    echo "6 - Generating the projects pages (missing projects title in projects pages headers)"
    cd content/projects; find . -type f -iname '*.blurb' | sed -E 's:.\/(.+)\/(.+)\/(.*):echo "### [\2](\1/\2/)" >> \1.lang; cat \1/\2/\3 >> \1.lang; echo "" >> \1.lang:' | bash;
    ls *.lang | sed -E 's:(.*).lang:echo "## \1" >> index.txt; cat \1.lang >> index.txt:'|bash
    cat ../_header.html > index.html; sed "s%projects nohl%projects highlighted%" ../_nav.html>> index.html
    multimarkdown index.txt >> index.html
    find . -type f -iname '*.md'| sed -E 's:.\/(.+)\/(.+)\/(.*):cat ../_header.html > \1/\2/index.html;echo "\2" >> \1/\2/index.html; sed "s%projects nohl%projects highlighted%" ../_nav.html >> \1/\2/index.html;  multimarkdown & >> \1/\2/index.html; cat ../_footer.html >> \1/\2/index.html:' | bash; rm index.txt; rm *.lang
    cd ../../
    echo "7 - Generating notes pages"
    ### Notes
    # into notes/index.html: links to the notes of level 2, individual note pages.
    # into notes/index.html: level 1 notes inline with title link, individual note pages.
    cd content/notes
    # depth 2
    # Find the depth-2 folders, >> name to
    # find directories and write the title of their content to a dirname.index file
    find . -type f -iname '*.index' -delete;
    find . -type f -iname '*.html' -delete;
    cat ../_header.html > index.html ; sed "s:notes nohl:notes highlighted:" ../_nav.html >> index.html;

    # in each folder, create an eponymous file that contains links (with title) to the folder's notes
    find . -type f -iname '*.md' -mindepth 2| cut -d '/' -f 2-| sed -E 's:(.+)/(.+).md:echo "<span class=\\"title\\"><a href=\\"/notes/\1/\2.html\\">">>\1/\1.index;head -n 1 \1/\2.md >> \1/\1.index; echo "</a></span>">> \1/\1.index;:'| bash

    # put these header files into the notes/index.html file
    find . -type f -iname '*.index' | cut -d '/' -f 2- | sed -E 's:(.+)/(.+).index:echo "<div class=\\"note folder\\"><a href=\\"\1/\\">\2</a>">> index.html; cat \1/\2.index >>index.html; echo "</div>" >> index.html:'| bash

    # In each directory, create an index.html with the directory title and the basic head.
    find . -type d -mindepth 1| cut -d '/' -f 2-| sed -E 's:(.+):cat ../_header.html > \1/index.html; sed "s%notes nohl%notes highlighted%" ../_nav.html>> \1/index.html ; echo "<div class=\\"note_folder\\"><h2><a href=\\"/notes/\1/\\">\1</a></h2>">>\1/index.html:'| bash

    # generate the individual notes in the sub-"notes" folders
    find . -type f -mindepth 2 -iname '*.md' |  cut -d '/' -f 2- |sed -E 's:(.+)/(.+).md:cat ../_header.html > \1/\2.html; sed "s%notes nohl%notes highlighted%" ../_nav.html >> \1/\2.html; echo "<div class=\"note_folder\"><a href=\"/notes/\1\">\1</a></div><div class=\"note\"><h2><a href=\"/notes/\1/\2.html\">">>\1/\2.html;head -n 1 & >> \1/\2.html; echo "</a></h2>">> \1/\2.html;  sed -e "1d" & > tmp.txt; multimarkdown tmp.txt >> \1/\2.html;echo "</div>" >> \1/\2.html ; cat ../_footer.html >> \1/\2.html:'| bash

    # Append the notes in the notes folder to the notes index.html
    find . -type f -iname '*.md' -mindepth 2 | sed -E 's:(.+)/(.+).md:echo "<div class=\"note\"><h2><a href=\"/notes/\1/\2.html\">">>\1/index.html;head -n 1 \1/\2.md >> \1/index.html; echo "</a></h2>">> \1/index.html;  sed -e "1d" \1/\2.md > tmp.txt; multimarkdown tmp.txt >> \1/index.html;echo "</div>" >> \1/index.html:'| bash

    # generate the individual notes in the "notes" folder
    find . -type f -maxdepth 1 -iname '*.md' | sed -E 's:(.+).md:echo "<div class=\"note\"><h2><a href=\"/notes/\1.html\">">>\1.html;head -n 1 \1.md >> \1.html; echo "</a></h2>">> \1.html;  sed -e "1d" \1.md > tmp.txt; multimarkdown tmp.txt >> \1.html;echo "</div>" >> \1.html ; cat ../_footer.html >> \1.html:'| bash

    # Append the notes in the notes folder to the notes index.html
    find . -type f -iname '*.md' -maxdepth 1 | sed -E 's:(.+).md:echo "<div class=\"note\"><h2><a href=\"/notes/\1.html\">">>index.html;head -n 1 \1.md >> index.html; echo "</a></h2>">> index.html;  sed -e "1d" \1.md > tmp.txt; multimarkdown tmp.txt >> index.html;echo "</div>" >> index.html:' | bash; cat ../_footer.html >> index.html
    cd ../../
    echo "8 - Generating the homepage"
    # Like notes but without nesting
    #
    ### Index:
    # _header.html
    # _nav.html # (general nav)
    # pages/index.md
    # last blog post
    # footer
    cd content; cat _header.html _nav.html > index.html; multimarkdown pages/home.md >> index.html; cat _home-middle.html blog/index-blog.html _footer.html >> index.html;
    cd ..
    echo "9 - Finishing the blog homepage"
    cd content/blog/
    cat ../_header.html > index.html ;  sed "s%blog nohl%blog highlighted%" ../_nav.html>> index.html
    cat index-blog.html ../_footer.html >> index.html
    ls *.html
    rm index-blog.html
    cd ../../
    echo "10 - Generating single pages"
    ### Colophon etc...
    # _header.html
    # _nav.html # (general nav)
    # pages/page.md
    # _footer.html
    cd content/pages/
    ls *.md | sed -E 's:(.+).md:cat ../_header.html > \1.html; head -n 1 \1.md >> \1.html ; cat ../_nav.html >> \1.html; sed -e "1d" & > tmp.txt ; multimarkdown tmp.txt >>\1.html; cat ../_footer.html >> \1.html:'|bash
    rm home.html
    cd ../../
    exit
fi


echo "usage : ___.sh init new [title] clean gen";cat ___.sh | grep "echo \" " |bash

##############
# todo : rename each project.text into index.text
# then I can transform each non-blog file into its html version based on content/[dir]/whatever/file.text

# find . -type f -iname '*.text'| grep -v '^./blog/' | sed -E 's:./([^/]+)/(.*).text:\1 \2:'
##############

# Blog post:
