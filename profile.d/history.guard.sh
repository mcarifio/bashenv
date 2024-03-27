# add _history to PROMPT_COMMAND so that all bash shells can see everyone else's commands
# might get expensive when the history is long but haven't been a problem.
history.prompt() {
     history -a
     history -c
     history -r
}
f.x history.prompt

history.env() {
    : 'history.env [${_size}]'
    export HISTSIZE=${1:-10000}
    export HISTFILESIZE=$(( 10 * HISTSIZE ))
    export HISTCONTROL=$HISTCONTROL:ignorespace:ignoredups
    PROMPT_COMMAND+=( history.prompt )
}
f.x history.env

history.session() {
    shopt -s histappend
}
f.x history.session
history.session

loaded "${BASH_SOURCE}"

