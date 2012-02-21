cd blog;
cat ../_feed-top > feed.xml
echo "<updated>`date '+%Y/%m/%d %H:%M:%S'`</updated>">> feed.xml;echo "<rights>Copyright © `date '+%Y'`">> feed.xml;finger `whoami`| head -n 1 | sed -E "s|.*Name:(.*)$|\1|">>feed.xml; echo "</rights>" >> feed.xml
echo "Creating the feed" # this used to generate a bash file and execute it, now it just generate the content of the bash file and send that to bash.
ls *.md|sort -r| sed -E 's#(....)_(..)_(..).(.*).md#echo \1 \2 \3 \4;echo "<entry><title>">> feed.xml; head -n 1 \1_\2_\3.\4.md |sed "s:\#\*::g" >> feed.xml;echo "</title><link type=\\"text/html\\" href=\\"\1/\2/\3/\4.html\\"/><updated>">>feed.xml;date -r `stat -f "%m" \1_\2_\3.\4.md` "+%Y/%m/%d %H:%M:%S" >>feed.xml;echo "</updated><content type=\\"html\\"><![CDATA[">> feed.xml;sed -e "1d" \1_\2_\3.\4.md|multimarkdown >> feed.xml;echo "]]></content></entry>">>feed.xml#'  | bash

echo "</feed>" >> feed.xml
