PS1.env() {
    export __bashenv_PS1_initial="${PS1}"
    export p=' '
}
f.x PS1.env

PS1.session() {
    PS1="${__bashenv_PS1_initial}\$p "
}
f.x PS1.session

sourced || true

