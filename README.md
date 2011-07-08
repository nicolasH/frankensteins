## Frankenstein's ___

_By Nicolas Hoibian._

\___.sh : _The answer to your questions about static html blogs in
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
`cat`, `echo`, `date`, `mkdir` etc..., has no option and uses almost
no variable.


## ___.sh


This script generates a `blog/index.html` with the latest post and
the list of older posts. For each posts (which should be markdown
files in the `blog/` dir and with named like
`yyyy\_mm\_dd.Prettyfied-title-here.md`) it will generate an html file
at `yyyy/mm/dd/Prettyfiled-title-here.html`. Each post title will be
put in a link to itself.

There is a newborn blog using it at [displayator.com](http://www.displayator.com/blog/).



### First time usage:

1. install [multimarkdown][mmd].
2. clone _frankensteins_ to some directory.
3. `___.sh init`
4. `___.sh new "My First Post"`
5. `nano blog/2011_11_11.My-First-Post.md`
6. `emacs blog/\*-\*`
7. `___.sh gen`
8. `rsync -r blog user@some.remote.host.net:/home/public/`
9. you have a blog!


### Help:


`___.sh what?`

or 

`___.sh`



### Day to day usage:

1. `___.sh new "This is my new post"`
2. `Emacs blog/2011_11_11.1455.This-is-my-new-post.md`
3. `___.sh gen`
4. `rsync -r blog --exclude '*.md' user@some.remote.host.net:/home/public/`


## Licence

I hereby release this 'software' under the Creative Commons
BY-NA-SA. Have fun.

[mmd]:http://fletcherpenney.net/multimarkdown/
[jekyll]:http://jekyllrb.com/
[hyde]:http://ringce.com/hyde
[frank]:http://www.literature.org/authors/shelley-mary/frankenstein/chapter-05.html
