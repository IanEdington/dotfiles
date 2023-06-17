# Terminal Patterns
I've solved a lot of problems using bash and I'm starting to forget them.
This is a place to write them down so they are searchable in the place I write most of my bash.

Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/

Find files with given pattern and make file openable by intellij

    git grep -l ': MarketingEmailContentFilter' | sed "s|\(.*\)|file://$PWD/\1|g"

Use sed to coerce regex into copyable element list

    git grep -h 'override val template:' backend/backend-marketing-emails  | sed -E 's/.*[. ]([A-Z0-9_]*)$/"\1",/' | sort

Pipe filenames into grep

    git grep -l 'override val senderExposedName' | sed 's/.*= "\(.*\)"/"\1",/' | xargs grep 'override val template' | sed -E 's/.*[. ]([A-Z0-9_]*)$/"\1",/' | sort

Find instances of word, clean and count

    $ grep -o "Typo: In word '[^<]*" SpellCheckingInspection.xml | sed -E "s/Typo: In word '(.*)'/\1/" | awk '{print tolower($0)}' | sort | uniq -c | sort -r | sed -E 's/  *([0-9]*) (.*)/\1 | \2 | /' | head -n 100 | pbcopy

Colors:

    ColorOff='\033[0m'

    BG_BLACK='\033[40m'
    BG_RED='\033[41m'
    BG_GREEN='\033[42m'
    BG_YELLOW='\033[43m'
    BG_BLUE='\033[44m'
    BG_MAGENTA='\033[45m'
    BG_CYAN='\033[46m'
    BG_LIGHT_GRAY='\033[47m'

    BLACK='\033[0;30m'
    DARK_GRAY='\033[1;30m'
    BLUE='\033[0;34m'
    LIGHT_BLUE='\033[1;34m'
    GREEN='\033[0;32m'
    LIGHT_GREEN='\033[1;32m'
    CYAN='\033[0;36m'
    LIGHT_CYAN='\033[1;36m'
    RED='\033[0;31m'
    LIGHT_RED='\033[1;31m'
    PURPLE='\033[0;35m'
    LIGHT_PURPLE='\033[1;35m'
    BROWN='\033[0;33m'
    YELLOW='\033[1;33m'
    LIGHT_GRAY='\033[0;37m'
    WHITE='\033[1;37m'

    echo "----- BG COLORS -----"
    echo "$BG_BLACK BLACK BG $ColorOff"
    echo "$BG_RED RED BG $ColorOff"
    echo "$BG_GREEN GREEN BG $ColorOff"
    echo "$BG_YELLOW YELLOW BG $ColorOff"
    echo "$BG_BLUE BLUE BG $ColorOff"
    echo "$BG_MAGENTA MAGENTA BG $ColorOff"
    echo "$BG_CYAN CYAN BG $ColorOff"
    echo "$BG_LIGHT_GRAY LIGHT_GRAY BG $ColorOff"

    echo "----- TEXT COLORS -----"
    echo "$WHITE WHITE TEXT $ColorOff"
    echo "$BLACK BLACK TEXT $ColorOff"
    echo "$DARK_GRAY DARK_GRAY TEXT $ColorOff"
    echo "$BLUE BLUE TEXT $ColorOff"
    echo "$LIGHT_BLUE LIGHT_BLUE TEXT $ColorOff"
    echo "$GREEN GREEN TEXT $ColorOff"
    echo "$LIGHT_GREEN LIGHT_GREEN TEXT $ColorOff"
    echo "$CYAN CYAN TEXT $ColorOff"
    echo "$LIGHT_CYAN LIGHT_CYAN TEXT $ColorOff"
    echo "$RED RED TEXT $ColorOff"
    echo "$LIGHT_RED LIGHT_RED TEXT $ColorOff"
    echo "$PURPLE PURPLE TEXT $ColorOff"
    echo "$LIGHT_PURPLE LIGHT_PURPLE TEXT $ColorOff"
    echo "$BROWN BROWN TEXT $ColorOff"
    echo "$YELLOW YELLOW TEXT $ColorOff"
    echo "$LIGHT_GRAY LIGHT_GRAY TEXT $ColorOff"

Do something if a command succeeded/failed

    set +e
    git --no-pager grep $file_name > /dev/null
    the_command_succeeded=$(test $? = 0 && some_other_command_succeeded && echo true || echo false)
    set -e

    if the_command_succeeded; then
        echo "do something"
    fi

