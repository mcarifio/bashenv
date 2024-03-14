ysh() (
    : '$@ # run ysh with args, @see https://www.oilshell.org/ especially https://www.oilshell.org/release/latest/doc/ysh-tour.html'
    PS1='\$ ' command ysh "$@"
)
f.complete ysh

ysh.env() {
    # echo ${FUNCNAME}
    return 0 
}
f.complete ysh.env
