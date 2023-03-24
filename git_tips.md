
## get a clean commit on top of a messy merge

given `main` and `ian/new-feature`

from `ian/new-feature` branch:

1. merge theirs into ours (fix conflicts)

    git merge main

2. soft reset to their branch

    git reset --soft main

3. make commit with changes

    gct

