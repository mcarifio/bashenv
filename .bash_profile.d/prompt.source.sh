# history
export HISTSIZE=10000
export HISTFILESIZE=$(( 10 * HISTSIZE ))
shopt -s histappend
export HISTCONTROL=$HISTCONTROL:ignorespace:ignoredups

# add _history to PROMPT_COMMAND so that all bash shells can see everyone else's commands
# might get expensive when the history is long but haven't been a problem.
_history() {
     history -a
     history -c
     history -r
}; declare -fx _history



# TODO mike@carif.io: fix this
after.add() {
    local -r _phrase="${1:?'expecting a phrase'}"
    PROMPT_COMMAND+=( "${_phrase}" )
}; declare -fx after.add

after.add _history
