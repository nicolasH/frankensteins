## Frankenstein's \_\_\_

_By Nicolas Hoibian._

\_\_\_.sh : _The answer to your questions about static html blogs in
42 line of bash (and thousands of lines of C)._

>_"His limbs were in proportion, and I had selected his features as
>beautiful. Beautiful!--Great God! His yellow skin scarcely covered
>the work of muscles and arteries beneath; his hair was of a lustrous
>black, and flowing; his teeth of a pearly whiteness; but these
>luxuriances only formed a more horrid contrast with his watery eyes,
>that seemed almost of the same colour as the dun white sockets in
>which they were set, his shrivelled complexion and straight black
>lips."_ - Mary Shelley, '[Frankenstein][frank]'

This software generates a static html blog from markdown compliant
files. It is similar in aim to [jekyll][] and [hyde][], but with a
smaller scope and much less elegance.

It is entirely UNIX based. The current version uses
[peg-multimarkdown][mmd] from Fletcher Peney.

It is a nameless, horrible and recursive assemblage of `bash`, `sed`,
`cat`, `echo`, `date`, `mkdir` etc..., has no option, no `for`, and
uses almost no variable.


## \_\_\_.sh


This script generates a `blog/index.html` with the latest post and the
list of 5 previous posts. For each markdown file in the `blog/`
directory named like `yyyy_mm_dd.Prettyfied-title-here.md`) it will
create an html file at `yyyy/mm/dd/Prettyfiled-title-here.html`. Each
post title will be put in a link to itself. It will also generate a
`blog/archives.html` file which contains a list of all the posts

There is a newborn blog using it at [displayator.com](http://www.displayator.com/blog/).



### First time usage:

1. install [multimarkdown][mmd].
2. clone _frankensteins_ to some directory.
3. `___.sh init`
6. `Emacs blog/*-*` # to edit the templates with your details
4. `___.sh new "My First Post"`
5. `nano blog/2011_11_11.My-First-Post.md`
7. `___.sh gen`
8. `rsync -r blog --exclude '*.md' user@some.remote.host.net:/home/public/`
9. you have a blog!


### Help:


`___.sh what?`

or

`___.sh`



### Day to day usage:

1. `___.sh new "This is my new post"`
2. `nano blog/2011_11_11.This-is-my-new-post.md`
3. `___.sh gen`
4. `rsync -r blog --exclude '*.md' user@some.remote.host.net:/home/public/`


## Explanations:

This script *generates* bash commands and execute them. As per
`bash` inner working:
- $0 is the name of the script. Should be `___.sh`
- $1 is the first parameter given to the script, here the name of the
  command you run: `init`, `new`, `gen` or `clean`.
- $2 is the second parameter given to the script. It's only used when
  creating a `new` script.


Here are some of the main generated commands explained.

### `new` command

    echo "$2" >> blog/`date +%Y_%m_%d.``echo $2 |sed 's:[\ \" \, \.\:\?_]:\-:g' | sed -e "s:':\-:g" | sed -e 's:\-\-*:\-:g'| sed -e 's:\-$::;s:^\-::'`.md;exit

This command creates a new blog post file with a filesystem friendly
name. The file name is based on the title of the post you want to
create and the date when you run the command. The file's first line
will be the given title.

`echo "$2" >> blog/ ` # write the given title to the file whose name is being created:

- the date:
`date +%Y_%m_%d.`:  Generates the date in an `ls` friendly format, e.g, `2011_12_31`
- the post title:
`echo $2 | # give the title to the following commands
    sed 's:[\ \" \, \.\:\?_]:\-:g' | # `s`ubstitues every [ ",.:?_] characters by '-'
    sed -e "s:':\-:g" |              # `s`ubstitues every  ['] character by -
    sed -e 's:\-\-*:\-:g'|           # `s`ubstitues multiple [-] by single [-]
    sed -e 's:\-$::;s:^\-::'`        # `s`ubstitues the first and last [-] of the title

- the extension:
  .md

- we exit so as not to run the `help` function
  ;exit

So for example if you decide to create a post entitled "Are Santa's -so cute- little helpers exploited?" on the 24th of December 2011, the title part of the file name is transformed progressively into :

    Are-Santa's--so-cute--little-helpers-exploited-
    Are-Santa-s--so-cute--little-helpers-exploited-
    Are-Santa-s-so-cute-little-helpers-exploited-
    Are-Santa-s-so-cute-little-helpers-exploited

So the final name is :
[date].[title].md -> 2011_12_24.Are-Santa-s-so-cute-little-helpers-exploited.md

### `gen` command

This command cleans up then generates the html version of each blog posts, the blog home page and the archive of each posts. Here are each steps of this command explained.

#### \#0 cleanup/directory creation

To generate the dates directory structure, the year, month and day are
read from each file.

To cleanup, each year for which there are post is removed:

    rm -r          # remove each directory which is returned by
                   # the sequence of commands bellow
    `ls *.md |        # each .md file
    cut -c 1-4 |      # the first 4 caracters of their file name
    sort |            # sorted
    uniq`;            # filtered so we only keep each year
    rm index.html archives.html # also generated files

To prepare the directories, the directories that will contain each blog post are created:

    mkdir -p       # create recursively each directory which is returned by the
                   # sequence of commands bellow (i.e. for 2011/12/24, create
                   # 2011, 2011/12 & 2011/12/24
    `ls *.md |        # Each post
    cut -c 1-10 |     # The first 10 characters of their file name: 2011_12_24
    sed 's#_#/#g'     # `s`ubstitue the _ by / -> 2011/12/24
    |sort | uniq`     # sorted and filtered so we only keep each day for which
                      # there is a post

#### \#1 Generate each individual post files

To create the html version of the posts, a (rather complex) command is generated for each post.

    ls *.md|       # each post
    sort -r|       # in reverse lexicographical order (2011_12_24 before 2010_12_25)
                   # for each post, some text is generated then executed
    sed 's#\(.\{10\}\)\.\(.*\)\.md# match the file name and store the date in \1 and the name in \2 , then replace everything by the text bellow. (not yet commands)
        echo \1 \1.\2.html >> titles;      # Write date and (for now incorrect) post file name to the title file
        head -n 1 TK\1.\2.md|              # Get the first line of the raw post (title) (*)
            sed "s:\#\*::g"                # Substitutes nothing to any sequence of '#'
            >> titles;                     # send the result to the titles file
        cat both-header >> \1.\2.html;     # Add the common headers to the (for now incorrectly named) post html file (*)
            head -n 1 TK\1.\2.md |         # Get the first line of the raw post (title)
            sed "s:\#\*::g"                # Substitutes nothing to any sequence of '#'
            >> \1.\2.html;                 # Add it to the post html file (*)
        cat post-body >> \1.\2\.html;      # Add the post-body file to the post html file (*)
        echo "<span class=\\"date\\">\1</span> <a href=\\"\2.html\\"> ">> \1.\2.html;
                                           # Add the date as a distinct html element to the html post file (*) and start a link to the file.
        multimarkdown TK\1.\2.md |         # Transform the post into its html version
            sed "1 s:>$:></a>:"            # Add the closing of an anchor to the end of the first line
            >> \1.\2\.html;                # And send it to its html file (*)
        cat both-footer >> \1.\2\.html;#' |# Add the page bottom the post html file (*)
    sed 's#_#\/#g'|                        # Correct the previous occurences of the post file name by replacing _ by /
        sed 's# TK\(....\)\/\(..\)\/\(..\)\.# \1_\2_\3.#g' | # correct the corrected occurences of the markdown filename back to their file location
        sed 's: \(....\/..\/..\)\.: \1\/:g' # for the html files, replace the dot between the day and the clean title by a /
    |bash     # and then run the previous text as if it was some correct sequence of commands.

#### \#2 Generate the index page

The index page of the blog will contain the last post and links to the previous 5 posts.

First, lets create the latest post part:

    cat both-header index-body >> index.html                   # The title of the last post is not put into the header
    ls *.md|sort -r|head -n 1|                                 # get the last post
    sed 's#\(....\).\(..\).\(..\).\(.*\).md#                   # get the all the components from the file name and replace them by the following text:
        echo "<span class=\"date\">\1\/\2\/\3</span> <a href=\\"\1\/\2\/\3\/\4.html\\">"; # echo the date element and the link to the post file
        multimarkdown \1\_\2\_\3.\4.md|                        # The html version of the post
        sed "1 s:>$:></a>:"#'                                  # Close the tag for the title
        |bash >> index.html                                    # Execute the previous text as if it was a command and write its output to the index.html.
    cat index-middle >>index.html                              # Add the separator between the post and the links to the previous five posts

Then add the links to the 5 preceding posts

    head -n 12 titles |                                          # Get the last 6 posts date, html file name and title
        sed -e :a -e '1,2d; /\(\.*\.html\)$/N; s/\n/\"\>/; ta' | # Ignore the first one, ? , replace the end of line by the closing of a tag
        sed 's:\(.\{11\}\)\.*\(.*\)                              # Match the date and the html file name part for replacement by
            :\<div class=\"index_item\"\>                        # A div containing
                <span class=\"date\">\1</span>                   # a span with the date
                <span class=\"date_sep\"> \&raquo\;</span>       #
                <span class=\"title\">                           # a span with a link to the title
                    <a href\=\"\2\<\/a\>                         #
                </span>\<\/div\>:'>>index.html                   # and send all that to the index file
    cat both-footer >> index.html                                # close the index file

#### \#3 Generate the archive 

Then lets create the archive page, which will contain a link to every post ever published:

    cat both-header  >> archives.html
    cat archives-body >> archives.html

Transform all the lines of the titles file into the Date Link Title format.

    sed -e :a -e '/\(\.*\.html\)$/N; s/\n/\"\>/; ta' titles |  # Ignore the first one, ? , replace the end of line by the closing of a tag
    sed 's:\(.\{11\}\)\.*\(.*\)                                # Then match the date and filename
        :\<div class=\"index_item\"\>                          # And replace it by a div containing
            <span class=\"date\">\1</span>                     # - The date of the post
            <span class=\"date_sep\"> \&raquo\;</span>         #
            <span class=\"title\">                             #
                <a href\=\"\2\<\/a\>                           # - A link to the post
            </span>\<\/div\>:'>> archives.html
    cat both-footer >> archives.html #;rm titles

The RSS fed is generated in a similar way to each posts, just with less `cat` of html files.

More explanations later.

## Licence

I hereby release this 'software' under the Creative Commons
BY-NA-SA. Have fun.

[mmd]:http://fletcherpenney.net/multimarkdown/
[jekyll]:http://jekyllrb.com/
[hyde]:http://ringce.com/hyde
[frank]:http://www.literature.org/authors/shelley-mary/frankenstein/chapter-05.html
