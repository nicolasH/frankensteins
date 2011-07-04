## Readme for Frankenstein's 

"His limbs were in proportion, and I had selected his features as
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

Usage:

clone the project. it will check out all the files in this repo,
including the 'templates' for the index and the posts.

then, run once 
`victor.sh init`
 which will rename the templates

`victor.sh new "Its Alive!"`

Will create a 

[mmd]:http://fletcherpenney.net/multimarkdown/
[jekyll]:http://jekyllrb.com/
[hyde]:http://ringce.com/hyde
