function zsh-stats() {
    fc -l 1 | awk '{CMD[$2]++ount++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a; }' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n25;
}

export HISTIGNORE="tr:ll:gd:gs"

