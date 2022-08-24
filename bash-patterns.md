# Terminal Patterns
I've solved a lot of problems using bash and I'm starting to forget them.
This is a place to write them down so they are searchable in the place I write most of my bash.

Find files with given pattern and make file openable by intellij

    git grep -l ': MarketingEmailContentFilter' | sed "s|\(.*\)|file://$PWD/\1|g"

Use sed to coerce regex into copyable element list

    git grep -h 'override val template:' backend/backend-marketing-emails  | sed -E 's/.*[. ]([A-Z0-9_]*)$/"\1",/' | sort

Pipe filenames into grep

    git grep -l 'override val senderExposedName' | sed 's/.*= "\(.*\)"/"\1",/' | xargs grep 'override val template' | sed -E 's/.*[. ]([A-Z0-9_]*)$/"\1",/' | sort
