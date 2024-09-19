#!/usr/bin/env bash

main() (
    local -r _message="restarted by $0"
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("${_message}", global.context)'
)

main "$@"





