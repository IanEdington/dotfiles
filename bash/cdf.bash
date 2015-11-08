cdf () {
    currFolderPath=$( /usr/bin/osascript << EOT
        tell application "Finder"
            try
        set currFolder to (folder of the front window as alias)
            on error
        set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
  EOT
    )
    echo "cd to \"$currFolderPath\""
    cd "$currFolderPath"
}
