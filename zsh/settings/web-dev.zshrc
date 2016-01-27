# find . -type d -exec chmod 755 {} \;
	chmodweb () {
		find $@ -type d -exec chmod 755 {} \;
		find $@ -type f -exec chmod 644 {} \;
	}

# edit hosts file quickly
alias hosts="sudo vim /etc/hosts"
