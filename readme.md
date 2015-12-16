
Built using [dotbot][1]

### dotfiles I really liked
https://github.com/mathiasbynens/dotfiles
https://github.com/anishathalye/dotfiles
https://github.com/holman/dotfiles
https://github.com/cowboy/dotfiles
https://github.com/skwp/dotfiles

### General philosophy
In creating this dotfile repo I was influenced by Zach Holman's "[Dotfiles Are Meant to Be Forked][2]" and Anish Athalye's "[Dotfiles Are Not Meant to Be Forked][3]". I took the linking style from Anish, the structure from Zach and functions from all over. I have extended these two ideas to create what I hope will be an easily modifiable dotfile set. The idea is that each package folder could be swapped in for any other folder and it will use those settings instead of the default. ie. if you don't like skwp's implementation of vim you can replace it with your own vim folder and everything will work as expected.

Dependancies

1. brew as much as is reasonable.
2. Use package managers where possible.
2. Use git submodules for anything that slips through the cracks.
3. Document anything that isn't managed.


[1]: https://github.com/anishathalye/dotbot
[2]: http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/
[3]: http://www.anishathalye.com/2014/08/03/managing-your-dotfiles/
