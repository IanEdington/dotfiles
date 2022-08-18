# Terminal Patterns
I've solved a lot of problems using bash and I'm starting to forget them.
This is a place to write them down so they are searchable in the place I write most of my bash.

Find files with given pattern and make file openable by intellij
git grep -l ': MarketingEmailContentFilter' | sed "s|\(.*\)|file://$PWD/\1|g"
