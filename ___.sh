#!/bin/bash

if [ "$1" = "init" ];then
    echo "         init : Creates the content directory and copies all the 'templates' files (_*.*) there."
    mkdir -p content/blog content/notes content/projects; cp _*.html _*.xml _*.css content/
    echo "You can now add the 'content' directory to a git repository and save it.";exit
fi

if [ "$1" = "new" ];then
    echo "  new [title] : Creates a blog post at blog/[current_date].[prettified title].md ."
    echo "$2" >> content/blog/`date +%Y-%m-%d.%H%M.``echo $2 |sed 's:[^[:alnum:]_]:-:g' | sed -e 's:--*:-:g'| sed -e 's:-$::;s:^-::'`.md;exit
fi

if [ "$1" = "clean" ];then
    echo "        clean : Removes the (generated) blog dates directories and all non-template html files."
    cd content && find . -type f \( -iname "*.html" ! -iname "_*" \) -exec rm {} \; ; cd blog; rm -r `ls *.md | cut -c 1-4 | sort | uniq`; rm titles feed.xml; cd ..;  exit
fi

if [ "$1" = "gen" ];then
    echo "          gen : Generates the blog, notes, projects and standalone pages"
    echo "0 - Removing the blog dates directory and all non-template html files"
    cd content && find . -type f \( -iname "*.html" ! -iname "_*" \) -exec rm {} \;
    cd blog; rm -r `ls *.md | cut -c 1-4 | sort | uniq`; rm titles feed.xml;
    echo "1 - Creating the year/month/day directories"
    mkdir -p `ls *.md | cut -c 1-10 | sed 's#\-#/#g'|sort | uniq`
    echo "2 - Creating the posts"
    ls *.md|sort -r| sed -E 's!(....)-(..)-(..)......(.*).md!echo \1/\2/\3 \1/\2/\3/\4.html >> titles;head -n 1 & |tr -d "#" >> titles;cat ../_header.html >> \1/\2/\3/\4.html;head -n 1 & |tr -d "#" >> \1/\2/\3/\4.html; echo " - Blog" >> \1/\2/\3/\4.html;sed "s%blog nohl%blog highlighted%" ../_nav.html >> \1/\2/\3/\4.html;echo "<div class=\\"post\\"><span class=\\"date\\">\1/\2/\3</span><span class=\\"title\\"><a href=\\"/blog/\1/\2/\3/\4.html\\"> ">> \1/\2/\3/\4.html;multimarkdown & | sed "1 s:>$:></a></span>:" >> \1/\2/\3/\4.html;echo "</div>" >> \1/\2/\3/\4.html;cat ../_blog-footer.html ../_footer.html >> \1/\2/\3/\4.html;!' | bash
    echo "3 - Creating the blog home page"
    cat ../_header.html > index.html; echo "Blog" >> index.html; sed "s%blog nohl%blog highlighted%" ../_nav.html >> index.html
    # Adding the latest post to the index page:
    ls *.md|sort -r|head -n 1|sed -E 's#(....)-(..)-(..)......(.*).md#echo "<span class=\\"date\\">\1\/\2\/\3</span> <span class=\\"title\\"> <a href=\\"/blog/\1\/\2\/\3\/\4.html\\">";multimarkdown &|sed "1 s:>$:></a></span>:"#'|bash >> index.html; cat ../_blog-sep.html >>index.html
    # Add the 5 previous posts titles+link to the bottom of the index page:
    head -n 12 titles | sed -E -e :a -e '1,2d; /(.*.html)$/N; s/\n/\"\>/; ta' | sed -E 's:(.{11})(.*):<div class="index_item"><span class="date">\1</span> <span class="title"><a href="/blog/\2</a></span>\</div>:'>>index.html; cat ../_blog-footer.html ../_footer.html >> index.html
    echo "4 - Creating the blog archive page"
    cat ../_header.html >> archives.html;echo "Archives - Blog" >> archives.html; sed "s%blog nohl%blog highlighted%" ../_nav.html >> archives.html; echo "<h2>Archives</h2>" >> archives.html
    # Transform all the lines of the titles file into the Date Link Title format.
    sed -E -e :a -e '/(.*.html)$/N; s/\n/">/; ta' titles | sed -E 's:(.{11})(.*):<div class=\"index_item\"><span class="date">\1</span> <span class="title"><a href="/blog/\2</a></span></div>:'>> archives.html
    cat ../_footer.html >> archives.html
    echo "5 - Creating the blog feed.xml"; cat ../_feed-top.xml > feed.xml
    ls *.md|sort -r| head -n 30 | sed -E 's@(....)-(..)-(..).(....).(.*).md@echo "<item><title>">> feed.xml; head -n 1 & |tr -d "#" >> feed.xml;echo "</title><link>" >> feed.xml; sed -n -E "s|^.*xml:base=\\"\(.*\)\\".*$|\\1/blog/\1/\2/\3/\5.html</link>|p" ../_feed-top.xml >> feed.xml;echo "<pubDate>`date -d "\1/\2/\3 \4" --rfc-822 2>/dev/null``date -j -f "%Y/%m/%d %H%M" "\1/\2/\3 \4"  "+%a, %d %b %Y %H:%M:%S %z" 2>/dev/null`</pubDate>" >>feed.xml;echo "<content:encoded><![CDATA[">> feed.xml;sed -e "1d" &|multimarkdown >> feed.xml;echo "]]></content:encoded></item>">>feed.xml@' | bash
    echo "</channel></rss>" >> feed.xml; cd ../../
    # Projects
    echo "6 - Generating the projects pages"
    cd content/projects; find */*/*.blurb | sed -E 's:(.+)\/(.+)\/(.*):echo "### [\2](\1/\2/)" >> \1.lang; cat \1/\2/\3 >> \1.lang; echo "" >> \1.lang:' | bash
    ls *.lang | sed -E 's:(.*).lang:echo "## \1" >> index.txt; cat \1.lang >> index.txt:'|bash
    cat ../_header.html > index.html; echo "Projects" >> index.html;  sed "s%projects nohl%projects highlighted%" ../_nav.html>> index.html
    multimarkdown index.txt >> index.html; cat ../_footer.html >> index.html
    ls */*/*.md| sed -E 's:(.+)\/(.+)\/(.*):cat ../_header.html > \1/\2/index.html;echo "\2" >> \1/\2/index.html; sed "s%projects nohl%projects highlighted%" ../_nav.html >> \1/\2/index.html; sed -E "1 s%^([#]*) (.*)$%\\1 [\\2](.)%" & | multimarkdown >> \1/\2/index.html; cat ../_footer.html >> \1/\2/index.html:' | bash; rm index.txt; rm *.lang; cd ../../
    # Notes
    echo "7 - Generating notes pages"
    cd content/notes; find . -type f -iname '*.index' -delete; find . -type f -iname '*.html' -delete;
    # Begin the notes/index.html page
    cat ../_header.html > index.html ; echo "Notes" >> index.html; sed "s:notes nohl:notes highlighted:" ../_nav.html >> index.html;
    # in each folder, create an eponymous file that contains links (with title) to the folder's notes
    find . -mindepth 2 -type f -iname '*.md' | cut -d '/' -f 2-| sed -E 's:(.+)/(.+).md:echo "<div><span class=\\"title\\"><a href=\\"/notes/\1/\2.html\\">">>\1/\1.index;head -n 1 \1/\2.md >> \1/\1.index; echo "</a></span></div>">> \1/\1.index;:'| bash
    # put these header files into the notes/index.html file
    find . -type f -iname '*.index' | cut -d '/' -f 2- | sed -E 's:(.+)/(.+).index:echo "<div class=\\"folder\\"><h1><a href=\\"/notes/\1/\\">\2/</a></h1>">> index.html; cat \1/\2.index >>index.html; echo "</div>" >> index.html:'| bash
    # In each directory, create an index.html with the directory title and the basic head.
    find . -mindepth 1 -type d | cut -d '/' -f 2-| sed -E 's:(.+):cat ../_header.html > \1/index.html; echo "\1" >> \1/index.html ; sed "s%notes nohl%notes highlighted%" ../_nav.html>> \1/index.html ; echo "<div class=\\"folder\\"><h1><a href=\\"/notes/\1/\\">\1/</a></h1>">>\1/index.html:'| bash
    # generate the individual notes in the sub-"notes" folders
    find . -mindepth 2 -type f  -iname '*.md' |  cut -d '/' -f 2- |sed -E 's:(.+)/(.+).md:cat ../_header.html > \1/\2.html; head -n 1 & | tr -d "#" >> \1/\2.html ; echo " - \1 - Notes" >> \1/\2.html ;sed "s%notes nohl%notes highlighted%" ../_nav.html >> \1/\2.html; echo "<div class=\"folder\"><h1><a href=\"/notes/\1\">\1/</a></h1></div><div class=\"note\"><h2><a href=\"/notes/\1/\2.html\">">>\1/\2.html;head -n 1 & >> \1/\2.html; echo "</a></h2>">> \1/\2.html;  sed -e "1d" & > tmp.txt; multimarkdown tmp.txt >> \1/\2.html;echo "</div>" >> \1/\2.html ; cat ../_footer.html >> \1/\2.html:'| bash
    # Append the notes in the notes folder to the notes index.html
    find . -mindepth 2 -type f -iname '*.md' | sed -E 's:(.+)/(.+).md:echo "<div class=\"note\"><h2><a href=\"/notes/\1/\2.html\">">>\1/index.html;head -n 1 \1/\2.md >> \1/index.html; echo "</a></h2>">> \1/index.html;  sed -e "1d" \1/\2.md > tmp.txt; multimarkdown tmp.txt >> \1/index.html;echo "</div>" >> \1/index.html:'| bash
    # Append the footer to the subfolder index pages.
    find . -mindepth 2 -type f -iname '*index.html'  | sed -E "s:(.*): cat ../_footer.html >> &:" |bash
    # generate the individual notes in the "notes" folder
    find . -maxdepth 1 -type f  -iname '*.md' | sed -E 's:(.+).md:cat ../_header.html > \1.html; head -n 1 & | tr -d "#" >> \1.html ; echo " - Notes" >> \1.html ; sed "s%notes nohl%notes highlighted%" ../_nav.html >> \1.html; echo "<div class=\"note\"><h2><a href=\"/notes/\1.html\">">>\1.html;head -n 1 \1.md >> \1.html; echo "</a></h2>">> \1.html;  sed -e "1d" \1.md > tmp.txt; multimarkdown tmp.txt >> \1.html;echo "</div>" >> \1.html ; cat ../_footer.html >> \1.html:'| bash
    # Append the notes in the notes folder to the notes index.html
    find . -maxdepth 1 -type f -iname '*.md'  | sed -E 's:./(.+).md:echo "<div class=\\"note\\"><h2><a href=\\"/notes/\1.html\\">">>index.html;head -n 1 & >> index.html; echo "</a></h2>">> index.html;  sed -e "1d" \1.md > tmp.txt; multimarkdown tmp.txt >> index.html;echo "</div>" >> index.html:' | bash; cat ../_footer.html >> index.html; rm tmp.txt; cd ../../
    # Home page
    echo "8 - Generating the homepage"
    cd content; cat _header.html > index.html; head -n 1 pages/home.md | tr -d "#" >> index.html; cat _nav.html >> index.html; sed -e "1d" pages/home.md |  multimarkdown >> index.html
    cd blog; ls *.md|sort -r|head -n 1|sed -E 's#(....)-(..)-(..)......(.*).md#echo "<span class=\\"date\\">\1\/\2\/\3</span> <span class=\\"title\\"> <a href=\\"/blog/\1\/\2\/\3\/\4.html\\">";multimarkdown &|sed "1 s:>$:></a></span>:"#'|bash >> ../index.html
    cat ../_blog-sep.html >> ../index.html; head -n 12 titles | sed -E -e :a -e '1,2d; /(.*.html)$/N; s/\n/\"\>/; ta' | sed -E 's:(.{11})(.*):<div class="index_item"><span class="date">\1</span> <span class="title"><a href="/blog/\2</a></span>\</div>:'>>../index.html
    cat ../_blog-footer.html ../_footer.html >> ../index.html;  cd ../../
    # Plain pages
    echo "9 - Generating single pages"
    cd content/pages/
    ls *.md | sed -E 's:(.+).md:cat ../_header.html > \1.html; head -n 1 \1.md | tr -d "#" >> \1.html ; sed "s%\1 nohl%\1 highlighted%" ../_nav.html >> \1.html ; sed -E "1 s%^([#]*) (.*)$%\\1 [\\2](/pages/\1.html)%" & | multimarkdown >> \1.html; cat ../_footer.html >> \1.html:'|bash
    rm home.html; cd ../../
    exit
fi

echo "usage : ___.sh init new [title] clean gen";cat ___.sh | grep "echo \" " | grep " : "|bash
