## Frankenstein's \_\_\_.sh

_By Nicolas Hoibian._

\_\_\_.sh : _The answer to your questions about static html sites in
-42- 82  line of bash (and thousands of lines of C)._

>_"His limbs were in proportion, and I had selected his features as
>beautiful. Beautiful!--Great God! His yellow skin scarcely covered
>the work of muscles and arteries beneath; his hair was of a lustrous
>black, and flowing; his teeth of a pearly whiteness; but these
>luxuriances only formed a more horrid contrast with his watery eyes,
>that seemed almost of the same colour as the dun white sockets in
>which they were set, his shrivelled complexion and straight black
>lips."_ - Mary Shelley, '[Frankenstein][frank]'

This software generates a static html site from markdown files. It is
similar in aim to [jekyll][] and [hyde][], but with a smaller scope
and much less elegance.

It is entirely UNIX based. The current version uses
[peg-multimarkdown][mmd] from Fletcher Peney.

It is a nameless, horrible and recursive assemblage of `bash`, `sed`,
`cat`, `echo`, `date`, `mkdir` etc..., has no option, no `for`, and
uses almost no variable.


## \_\_\_.sh


This script generates a website from a set of Markdown files. It
transform the files into HTML pages in 4 (+1) different ways depending
on which folder the files are in. In general, each transformed page
will consist of concatenating the `_header.html`, `_nav.html`, content
and `_footer.html` together into a single html page. The content is
usually the result of a markdown to html conversion, surrounded with
some specific transformations, which are slightly different for each
folder.

**In the _blog_ folder**, the files should be named
  `yyyy-mm-dd.hhmm.this-is-the-title.md`. You can create a blog file
  empty but for the title using '`___.sh new "This is the
  title"`'. During the `gen` phase, they will be transformed into
  individual post at `yyyy/mm/dd/this-is-the-title.html`. An
  `archive.html` page will also be generated, containing a list of all
  the blog posts, most recent first. A full text RSS feed will also be
  generated containing all the posts. In the blog/ directory, an
  `index.html` will be generated, containing the last post as well as
  links to the 5 previous posts. The latest blog post and links to the
  5 previous ones will also appear on the front page.

**In the _notes_ folder**, the files can be organized in as many
  folders as you want, but sub-folders will not be taken into account
  (notes/bla/this.md will be used, but not notes/bla/bla/that.md). The
  notes will be transformed into their html version. There will also
  be an index.html file which will contain the full text of the notes
  in the current folder. In the notes folder, the list of notes in
  folders will appear at the top of the page.

**In the _projects_ folder**, the minimum folder depth should be two
  (`projects/category/project1`). In each project folder, the script
  looks for a `project1/project1.blurb` and a `project1/project1.md`
  file. For each category, the blurb file will be assembled and shown
  on the top-level projects index page (`projects/index.html`), and
  the individual projects `.md` file will be transformed into an
  index.html page in the project folder.

**In the _pages_ folder**, the `.md` files will be transformed into
  `.html` file. If there is a `home.md` file, it will be used to
  create the site home page (it will appear above the latest blog
  post). Sub-folders are not supported.


### Commands

There are four commands: `init`, `new`, `clean` and `gen`.

- `init` is used the first time you check out this project. It will
  create the `content` directory and the necessary sub-folders. It
  will move the template files and the stylesheet into the `content`
  directory. Once this is done, you do not need to run it again. If
  you do, it will overwrite the templates and the stylesheet.

- `new`
- `clean`
- `gen` 

### Implementation details

_Conventions_:

- `_name`: this is one of the template files you have to edit. It
  should be named `_name.html` in the content folder.
- `[... post]`: this is content extracted from a markdown file. Either
  the first line of a file ("_'s title_") or the result of a markdown
  to html conversion.


#### Initial run 

Please run `___.sh init` so the content folders (content + /blog
/projects /notes /pages)are created and the template files are moved
to where they will be used.

#### Blog

You can use `___.sh new "A new beginning!"` to create a file (named,
say `2014-07-07.0707.A-new-beginning.md`) in the blog folder that will
contain the title. It will be named using the date, and most special
characters will be removed from the file name (but not the title).

Generation phase: When `___.sh gen` is invoked, all the blog posts
will be transformed into html pages, in a
`YYYY/MM/DD/The-title-of-the-post.html` file. The latest post
will also be used to create an `index.html` in the blog folder. The
titles and links to each post will be part of the `archive.html` page,
and the last five titles and links will be added to the end of the
`index.html` page. All the posts will also be used to generate a full
text `blog/feed.xml`.

How each pages are assembled: 

Posts: 

    _header 
    + [post's title] 
    + _nav*
    + [post] 
    + _blog-footer 
    + _footer

index.html: 

    _header 
    + [first line of latest post] + "Blog" 
    + _nav*
    + [latest post] 
    + _blog-sep 
    + [previous 5 posts] 
    + _blog-footer 
    + _footer
    
archive.html:

    _header 
    + "Archive" 
    + _nav*
    + [titles and links to all the posts] 
    + _footer
    
feed.xml: 

    _feed-top 
    + [every posts]



#### Notes

Just write your notes. Upon generation, each note will be transformed into its html
version. Each folder will have an index page with the notes in full
text and, for the root `notes` folder, the list of sub-folders and the
their notes' titles will appear at the top of the `notes/index.html`
page. For individual notes, the URL will be the filename with '.md'
replaced by '.html'

How each pages are assembled:

notes/index.html:

    _header 
    + "Notes" 
    + _nav* 
    + [list of sub-folders and their notes titles (as links)] 
    + [each note in the folder] 
    + _footer
    
notes/a-single-note.md -> notes/a-single-note.html:

    _header 
    + [note's title] + "Notes" 
    + _nav*
    + [content] 
    + _footer
    
    
notes/folder/index.html: 


    _header 
    + [folder name]  + "Notes" 
    + _nav* 
    + [all the folder's notes] 
    + _footer
    
    
notes/folder/another-note.md -> notes/folder/another-note.html:

    _header 
    + [note's title] + folder + "Notes"
    + _nav*
    + [another-note.md] 
    + _footer
    
    
#### Projects

The projects part was born of the way I arranged mine on my website:
`language/projects`. Each project folder contains a `project.blurb`
and a `project.md`. When the site is baked, the blurb are aggregated
and arranged below the category name on the Projects page, and each
project's markdown file is transformed into an `index.html` page.

For example, given the following list of projects and languages:

    |-Java
      |-Displayable
        |-Displayable.blurb
        |-Displayable.md
      |-DisplayableCreator
        |-DisplayableCreator.blurb
        |-DisplayableCreator.md
    |-Javascript
      |-nTime
        |-nTime.blurb
        |-nTime.md
        
The Projects page would look like that (projects/index.html):

    _header 
    + "Projects"
    + _nav*
    
    + java**
    + [Displayable.blurb]
    + [DisplayableCreator.blurb]

    + Javascript**
    + nTime**
    + [nTime.blurb]   
    
    + _footer


The DisplayableCreator folder would contain a generated index page
(projects/java/DisplayableCreator/index.html):

    _header 
    + [project's title] + "Projects" 
    + _nav*
    + [project.md] 
    + _footer
    
**: the folder's name


#### Pages

The pages `.md` files will simply be transformed into a `.html` version:

    _header 
    + [page's title] 
    + _nav* 
    + [content] 
    + _footer
    
Except for a "home.md" page if present, which would be incorporated into
the root `index.html`.

    _header 
    + [home title] 
    + _nav*
    + [home.md] 
    + [latest blog] 
    + _blog-sep 
    + [last 5 posts] 
    + _blog-footer 
    + _footer


#### \_nav

In the above representation, the nav is transformed so it is possible
to highlight the current part of the site the page is in. The default
`_nav.html` page contains links with a class that is composed of a
name (blog|notes|project) and " nohl". When generating html pages, the
composite class is matched and the "nohl" part is replaced with
"highlighted". For _notes_, _blog_ and _projects_ only '_notes_', '_blog_' and
'_projects_' are looked for.  In the `pages` directory, the file name is
looked for. So if there is `colophon.md` page and a `"colophon nohl"`
class in the `_nav` file, the class will become `"colophon highlighted"` in the`colophon.html` page.


--- 

Released under the GPL v3

Copyright Nicolas Hoibian 2014
