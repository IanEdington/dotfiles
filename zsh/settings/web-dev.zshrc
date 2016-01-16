# find . -type d -exec chmod 755 {} \;
	chmodweb () {
		find $@ -type d -exec chmod 755 {} \;
		find $@ -type f -exec chmod 644 {} \;
	}

