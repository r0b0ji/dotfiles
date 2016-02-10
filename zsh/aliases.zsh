# Use colors in coreutils utilities output
#alias ls='ls --color=auto'
alias grep='grep --color'
alias ls='ls -G'
alias la='ls -Gla'

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# Common Util functions
function largestN() {
    N="$1";
    find -type f -printf "%s\\t%p\\n" | sort -nr | head -n $N | gawk 'BEGIN{FS="\t"}{ size_kb=$1/1048576; print size_kb " MB\t" $2}'
}
