## Readme for Frankenstein's 

_The answer to your questions about blogging in 42 line of bash (and
thousands of lines of C)._

>"His limbs were in proportion, and I had selected his features as
beautiful. Beautiful!--Great God! His yellow skin scarcely covered the
work of muscles and arteries beneath; his hair was of a lustrous
black, and flowing; his teeth of a pearly whiteness; but these
luxuriances only formed a more horrid contrast with his watery eyes,
that seemed almost of the same colour as the dun white sockets in
which they were set, his shrivelled complexion and straight black
lips." 
- Mary Shelley, 'Frankenstein'

The goal of this software is to generate a static html blog from
markdown compliant files. It is similar in aim to [jekyll][] and
[hyde][], but with a smaller scope and much less elegance.

It is mostly UNIX based. The current version uses [peg-multimarkdown from
Fletcher Peney][mmd]. 

It is a horrible assemblage of bash, sed, cat, echo, date, mkdir
etc... which uses almost no variable.

### First time usage:

1. install [multimarkdown][mmd].
2. clone the project to some directory.
3. `victor.sh init`
4. `victor.sh new "My First Post"`
5. `nano blog/2011_11_11.1337.My-First-Post.md`
6. `victor.sh gen`
7. `rsync -r blog --exclude '*.md' user@some.remote.host.net:/home/public/`
8. you have a blog!

### Day to day usage:

1. `victor.sh new "This is my new post"`
2. `Emacs blog/yyyy\_mm\_dd_hh.mm.this-is-my-new-post.md`
3. `victor.sh gen`
4. `rsync -r blog --exclude '*.md' user@some.remote.host.net:/home/public/`

[mmd]:http://fletcherpenney.net/multimarkdown/
[jekyll]:http://jekyllrb.com/
[hyde]:http://ringce.com/hyde
