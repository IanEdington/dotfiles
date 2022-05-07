# Manage packages using git subtree

Add package:

    git subtree add --prefix packages/diff-so-fancy https://github.com/so-fancy/diff-so-fancy.git master --squash

Update packages using:

    git subtree pull --prefix packages/diff-so-fancy https://github.com/so-fancy/diff-so-fancy.git master --squash

