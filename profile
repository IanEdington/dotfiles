# BASH configs and aliases
## From IanEdington

#### Table of Contents:
##### 0. Personalization
##### 1. Environment Configuration
###### 1.1 Python dev environment
###### 1.2
##### 2. Set defaults and add functionality to standard Commands
##### 3. GUI quick links
##### 4. Comand line Applications
###### 4.1 Docker
##### 5. File and Folder Management
##### 6. Searching
##### 7. Process Management
##### 8. Networking
##### 9. Systems Operations & Information
##### 10. Web Development
##### 11. Reminders & Notes
###### Interesting commands I haven't gotten to yet


## 0. Personalization ##

#### import the bookmarks file from .config/setup/bookmarks.md: these are files I cd to often (change the most often too).

	source ~/.config/bash/bookmarks.bash

###### MongoDB

	alias mongodev='mongod --dbpath ~/.env/mongodb/data/'

#### Edit the .profile file
	alias .profile='edit ~/.profile'

#### Pretty Prompt:
	export PS1='\[\033[0;33m\]\u@\h\[\033[0;35m\]$\[\033[00m\] '
#### Set Paths
	export PATH="/usr/local/bin:$PATH"
	export PATH="/usr/local/share/python:$PATH"
	export PATH="/usr/local/mysql/bin:$PATH"
#### Set Default Editor
	export EDITOR=/usr/bin/nano
#### Set default blocksize for ls, df, du
	export BLOCKSIZE=1k
#### Add color to terminal (I use Mac Terminal Profiles instead)
	export CLICOLOR=1
	export LSCOLORS=ExFxBxDxCxegedabagacad
#### Other environment Variables:
	export NLTK_DATA="~/Dropbox/dev/datasets/nltk_data"


# 1. ENVIRONMENT CONFIGURATION #

#### 1.1 Python Dev Environment ####
###### Activate Python virtual environment at .env/ (for project folders)
	alias .env='source .env/bin/activate'
#### Activate Anaconda environments (3.4 & 2.7)
	alias anaconda='anaconda3'
	alias anaconda3='source ~/.env/anaconda3/bin/activate conda3.4'
	alias anaconda2='source ~/.env/anaconda3/bin/activate conda2.7'
######Preferred 'ipython' implementations
	alias ipyterm='ipython qtconsole &'
	alias ipynote='ipython notebook'
	alias ipyserv='ipython notebook --profile=nbserver'

###### MongoDB

	alias mongodev='mongod --dbpath ~/.env/mongodb/data/'

# 2. Set defaults and add functionality to standard Commands #

#### ls (and derivatives)
###### ls - Always list directory path and perfered ls view
	alias ls='pwd; ls -AFG'
		# A: list all except . & ..
		# F: '/' = directory, '*' = executable, '@' = link, '=' = socket, '%' = whiteout, '|' = FIFO
		# G: Enable colorized output
		# ll - Long List alias 'ls -l' implementation
	alias ll='ls -AFGlh'
		# l: List in long format
		# h: use unit suffixes: Byte, Kilobyte, Megabyte, Gigabyte ...
		# lr: Full Recursive Directory Listing (I don't understand this)
	alias lr="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
	alias filetree='lr'
	alias ft='lr'
#### cd
######	Always list directory contents
	cd () { builtin cd "$@"; ls; }
###### make it easier to cd
	alias ~="cd ~"
	alias cd..='cd ../'
	alias ..='cd ../'
	alias ...='cd ../../'
	alias .3='cd ../../../'
	alias .4='cd ../../../../'
	alias .5='cd ../../../../../'
	alias .6='cd ../../../../../../'
###### cdf: 'cd to frontmost window of MacOS Finder
	source ~/.config/bash/cdf.bash
#### cp
	alias cp='cp -Ri'
#### scp
	# alias scp='scp -C'
#### Preferred 'mv' implementation
	# alias mv='mv -iv'
#### Preferred 'mkdir' implementation
	# alias mkdir='mkdir -pv'
#### Preferred 'less' implementation
	# alias less='less -FSRXc'
#### c: Clear terminal display
	alias c='clear'
#### which: Find executables
	alias which='type -all'
#### path: Echo all executable Paths
	alias path='echo -e ${PATH//:/\\n}'
#### trash: Moves a file to the MacOS trash
	trash () { command mv "$@" ~/.Trash ; }
	alias tr='trash'
#### ql: Opens any file in MacOS Quicklook Preview
	ql () { qlmanage -p "$*" >& /dev/null; }


# 3. GUI quick links
###### stree Open in Sourcetree
	alias sourcetree='stree'
###### f: Opens in Finder
	alias f='open -a Finder ./'
###### edit: Opens in atom
	alias edit='atom'



# 4. Comand line Applications

#### 4.1 Docker
###### Docker-Quickstart
	docker-quickstart () {
		docker-machine start default;
		docker-machine env default;
		eval "$(docker-machine env default)";
		clear;
	}
#### 4.2 Git
###### Tab-completion
	source ~/.config/git/git-completion.bash

# 5. File and Folder Management #

####	zipf: To create a ZIP archive of a folder
	zipf () { zip -r "$1".zip "$1" ; }
####	numFiles: Count of non-hidden files in current dir
	alias numFiles='echo $(ls -1 | wc -l)'
####	make1mb: Creates a file of 1mb size (all zeros)
	alias make1mb='mkfile 1m ./1MB.dat'
####	make5mb: Creates a file of 5mb size (all zeros)
	alias make5mb='mkfile 5m ./5MB.dat'
####	make10mb: Creates a file of 10mb size (all zeros)
	alias make10mb='mkfile 10m ./10MB.dat'

#### extract: Extract most know archives with one command
	extract () {
	if [ -f $1 ] ; then
	case $1 in
	*.tar.bz2) tar xjf $1	 ;;
	*.tar.gz)	tar xzf $1	 ;;
	*.bz2)	 bunzip2 $1	 ;;
	*.rar)	 unrar e $1	 ;;
	*.gz)	gunzip $1	;;
	*.tar)	 tar xf $1	;;
	*.tbz2)	tar xjf $1	 ;;
	*.tgz)	 tar xzf $1	 ;;
	*.zip)	 unzip $1	 ;;
	*.Z)	 uncompress $1	;;
	*.7z)	7z x $1	;;
	*)	 echo "'$1' cannot be extracted via extract()" ;;
	 esac
	 else
	 echo "'$1' is not a valid file"
	fi
	}


# 6. Searching #

#### qfind: Quickly search for file
	alias qfind="find . -name "
#### ff: Find file under the current directory
	ff () { /usr/bin/find . -name "$@" ; }
#### ffs: Find file whose name starts with a given string
	ffs () { /usr/bin/find . -name "$@"'*' ; }
#### ffe: Find file whose name ends with a given string
	ffe () { /usr/bin/find . -name '*'"$@" ; }

#### spotlight: Search for a file using MacOS Spotlight's metadata
	spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }


# 7. Process Management #

#### findPid: find out the pid of a specified process
###### Note that the command name can be specified via a regex
###### E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
###### Without the 'sudo' it will only find processes of the current user
	findPid () { lsof -t -c "$@" ; }

#### memHogsTop, memHogsPs: Find memory hogs
	alias memHogsTop='top -l 1 -o rsize | head -20'
	alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#### cpuHogs: Find CPU hogs
	alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#### topForever: Continual 'top' listing (every 10 seconds)
	alias topForever='top -l 9999999 -s 10 -o cpu'

#### ttop: Recommended 'top' invocation to minimize resources
	alias ttop="top -R -F -s 10 -o rsize"

#### my_ps: List processes owned by my user:
	my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }


# 8. Networking #

#### myip: Public facing IP Address
	alias myip='curl ip.appspot.com'
#### netCons: Show all open TCP/IP sockets
	alias netCons='lsof -i'
#### flushDNS: Flush out the DNS Cache
	alias flushDNS='dscacheutil -flushcache'
#### lsock: Display open sockets
	alias lsock='sudo /usr/sbin/lsof -i -P'
#### lsockU: Display only open UDP sockets
	alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'
#### lsockT: Display only open TCP sockets
	alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'
#### ipInfo0: Get info on connections for en0
	alias ipInfo0='ipconfig getpacket en0'
#### ipInfo1: Get info on connections for en1
	alias ipInfo1='ipconfig getpacket en1'
#### openPorts: All listening connections
	alias openPorts='sudo lsof -i | grep LISTEN'
#### showBlocked: All ipfw rules inc/ blocked IPs
	alias showBlocked='sudo ipfw list'
#### ii: display useful host related informaton
	ii() {
	echo -e "\nYou are logged on ${RED}$HOST"
	echo -e "\nAdditionnal information:$NC " ; uname -a
	echo -e "\n${RED}Users logged on:$NC " ; w -h
	echo -e "\n${RED}Current date :$NC " ; date
	echo -e "\n${RED}Machine stats :$NC " ; uptime
	echo -e "\n${RED}Current network location :$NC " ; scselect
	echo -e "\n${RED}Public facing IP Address :$NC " ;myip
	echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
	echo
	}


# 9. Systems Operations & Information #

#### mountReadWrite: For use when booted into single-user
	alias mountReadWrite='/sbin/mount -uw /'
#### cleanupDS: Recursively delete .DS_Store files
	alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
#### finderShowHidden: Show hidden files in Finder
#### finderHideHidden: Hide hidden files in Finder
	alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
	alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'
#### cleanupLS: Clean up LaunchServices to remove duplicates in the "Open With" menu
	alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
#### screensaverDesktop: Run a screensaver on the Desktop
	alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'


# 10. Web Development #

#### apacheEdit: Edit httpd.conf
	alias apacheEdit='sudo edit /etc/httpd/httpd.conf'
#### apacheRestart: Restart Apache
	alias apacheRestart='sudo apachectl graceful'
#### editHosts: Edit /etc/hosts file
	alias editHosts='sudo edit /etc/hosts'
#### herr: Tails HTTP error logs
	alias herr='tail /var/log/httpd/error_log'
#### Apachelogs: Shows apache error logs
	alias apacheLogs="less +F /var/log/apache2/error_log"
#### httpHeaders: Grabs headers from web page
	httpHeaders () { /usr/bin/curl -I -L $@ ; }
#### httpDebug: Download a web page and show info on what took time
	httpDebug () { /usr/bin/curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; }


# 11. Reminders & Notes #

#### remove_disk: spin down unneeded disk
#### diskutil eject /dev/disk1s3

#### to change the password on an encrypted disk image:
#### hdiutil chpass /path/to/the/diskimage

#### to mount a read-only disk image as read-write:
#### hdiutil attach example.dmg -shadow /tmp/example.shadow -noverify

#### mounting a removable drive (of type msdos or hfs)
#### mkdir /Volumes/Foo
#### ls /dev/disk* to find out the device to use in the mount command)
#### mount -t msdos /dev/disk1s1 /Volumes/Foo
#### mount -t hfs /dev/disk1s1 /Volumes/Foo

#### to create a file of a given size: /usr/sbin/mkfile or /usr/bin/hdiutil
#### e.g.: mkfile 10m 10MB.dat
#### e.g.: hdiutil create -size 10m 10MB.dmg
#### the above create files that are almost all zeros - if random bytes are desired
#### then use: ~/Dev/Perl/randBytes 1048576 > 10MB.dat


# Interesting commands I haven't gotten to yet #

###### Show_options: display bash options settings
	# alias show_options='shopt'
###### fix_stty: Restore terminal settings when screwed up
	# alias fix_stty='stty sane'
###### cic: Make tab-completion case-insensitive
	# alias cic='set completion-ignore-case On'
###### mcd: Makes new Dir and jumps inside
	# mcd () { mkdir -p "$1" && cd "$1"; }
###### DT: Pipe content to file on MacOS Desktop
	# alias DT='tee ~/Desktop/terminalOut.txt'
###### mans: Search manpage given in agument '1' for term given in argument '2' (case insensitive)displays paginated result with colored search terms and two lines surrounding each hit. Example: mans mplayer codec
	# mans () {
	# man $1 | grep -iC2 --color=always $2 | less
	# }
###### showa: to remind yourself of an alias (given some part of it)
	# showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }
