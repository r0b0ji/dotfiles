# User customizable options
# PR_ARROW_CHAR="[some character]"
# RPR_SHOW_USER=(true, false) - show username in rhs prompt
# RPR_SHOW_HOST=(true, false) - show host in rhs prompt

# Nice prompt from office
#PROMPT_COLOR=${PROMPT_COLOR:-cyan}       # Set the prompt color; defaults to cyan
#PS1="%{${fg[$PROMPT_COLOR]}%}%B%n@%m] %b%{${fg[default]}%}"   # a nice colored prompt
#RPROMPT="%{${fg[$PROMPT_COLOR]}%}%B%(7~,.../,)%6~%b%{${fg[default]}%}"

# Set custom prompt

# Allow for variable/function substitution in prompt
setopt prompt_subst

# Load color variables to make it easier to color things
autoload -U colors && colors

# Make using 256 colors easier 
if [[ "$(tput colors)" == "256" ]]; then
    source ~/.zsh/plugins/spectrum.zsh
    # change default colors
    fg[green]=$FG[064]
    fg[cyan]=$FG[037]
    fg[blue]=$FG[033]
    fg[teal]=$FG[041]
    fg[red]=$FG[160]
    fg[orange]=$FG[166]
    fg[yellow]=$FG[136]
    fg[magenta]=$FG[125]
    fg[violet]=$FG[061]
    fg[brown]=$FG[094]
    fg[neon]=$FG[112]
    fg[pink]=$FG[183]
    fg[darkred]=$FG[088]
else
    fg[teal]=$fg[blue]
    fg[orange]=$fg[yellow]
    fg[violet]=$fg[magenta]
    fg[brown]=$fg[orange]
    fg[neon]=$fg[green]
    fg[pink]=$fg[magenta]
    fg[darkred]=$fg[red]
fi

# Current directory, truncated to 3 path elements (or 4 when one of them is "~")
# The number of elements to keep can be specified as ${1}
function PR_DIR() {
    local sub=${1}
    if [[ "${sub}" == "" ]]; then
        sub=3
    fi
    local len="$(expr ${sub} + 1)"
    local full="$(print -P "%d")"
    local relfull="$(print -P "%~")"
    local shorter="$(print -P "%${len}~")"
    local current="$(print -P "%${len}(~:.../:)%${sub}~")"
    local last="$(print -P "%1~")"

    # Longer path for '~/...'
    if [[ "${shorter}" == \~/* ]]; then
        current=${shorter}
    fi

    local truncated="$(echo "${current%/*}/")"

    # Handle special case of directory '/' or '~something'
    if [[ "${truncated}" == "/" || "${relfull[1,-2]}" != */* ]]; then
        truncated=""
    fi

    # Handle special case of last being '/...' one directory down
    if [[ "${full[2,-1]}" != "" && "${full[2,-1]}" != */* ]]; then
        truncated="/"
        last=${last[2,-1]} # take substring
    fi

    echo "%{$fg[green]%}${truncated}%{$fg[orange]%}%B${last}%b%{$reset_color%}"
}

# An exclamation point if the previous command did not complete successfully
function PR_ERROR() {
    echo "%(?..%(!.%{$fg[violet]%}.%{$fg[red]%})%B!%b%{$reset_color%} )"
}

# The arrow symbol that is used in the prompt
PR_ARROW_CHAR=">"

# The arrow in red (for root) or violet (for regular user)
function PR_ARROW() {
    echo "%(!.%{$fg[red]%}.%{$fg[violet]%})${PR_ARROW_CHAR}%{$reset_color%}"
}

# Set custom rhs prompt
# User in red (for root) or violet (for regular user)
RPR_SHOW_USER=true # Set to false to disable user in rhs prompt
function RPR_USER() {
    if [[ "${RPR_SHOW_USER}" == "true" ]]; then
        echo "%(!.%{$fg[red]%}.%{$fg[violet]%})%B%n%b%{$reset_color%}"
    fi
}

# Host in a deterministically chosen color
RPR_SHOW_HOST=true # Set to false to disable host in rhs prompt
function RPR_HOST() {
    local colors
    colors=(yellow pink darkred brown neon teal)
    local index=$(python -c "print(hash('$(hostname)') % ${#colors} + 1)")
    local color=$colors[index]
    if [[ "${RPR_SHOW_HOST}" == "true" ]]; then
        echo "%{$fg[$color]%}%m%{$reset_color%}"
    fi
}

# ' at ' in orange outputted only if both user and host enabled
function RPR_AT() {
    if [[ "${RPR_SHOW_USER}" == "true" ]] && [[ "${RPR_SHOW_HOST}" == "true" ]]; then
        echo "%{$fg[blue]%} at %{$reset_color%}"
    fi
}

# Build the rhs prompt
function RPR_INFO() {
    echo "$(RPR_USER)$(RPR_AT)$(RPR_HOST)"
}

PROMPT_MODE=0

# Function to toggle between prompt modes
function tog() {
    if [[ "${PROMPT_MODE}" == 0 ]]; then
        PROMPT_MODE=1
    elif [[ "${PROMPT_MODE}" == 1 ]]; then
        PROMPT_MODE=2
    else
        PROMPT_MODE=0
    fi
}

# Prompt
function PCMD() {
    if [[ "${PROMPT_MODE}" == 0 ]]; then
        echo "$(PR_DIR) $(PR_ERROR)$(PR_ARROW) " # space at the end
    elif [[ "${PROMPT_MODE}" == 1 ]]; then
        echo "$(PR_DIR 1) $(PR_ERROR)$(PR_ARROW) " # space at the end
    else
        echo "$(PR_ERROR)$(PR_ARROW) " # space at the end
    fi
}

PROMPT='$(PCMD)' # single quotes to prevent immediate execution
RPROMPT='' # set asynchronously and dynamically

# Right-hand prompt
function RCMD() {
    echo "$(RPR_INFO)";
}

ASYNC_PROC=0
function precmd() {
    function async() {
        # save to temp file
        printf "%s" "$(RCMD)" > "${HOME}/.zsh_tmp_prompt"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
    # read from temp file
    RPROMPT="$(cat ${HOME}/.zsh_tmp_prompt)"

    # reset proc number
    ASYNC_PROC=0

    # redisplay
    zle && zle reset-prompt
}
