path.add ~/.cargo/bin
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

cargo() (
    set -Eeuo pipefail
    local _invocation="${FUNCNAME} $@"
    command ${FUNCNAME} "$@" || return $(error "${FUNCNAME} $@ => $?")

    local _verb=''
    for _a in "${@}"; do
        case "${_a}" in
            --) shift; break;;
            -*) ;;
            *) _verb="${_a}"; shift; break;;
        esac
        shift
    done

    [[ install = "${_verb}" ]] || return 0
    echo ${_invocation} >> "$(bashenv.profiled)/binstall.d/cargo.script.binstall.sh"
)
f.x cargo


cargo.update.all() (
    set -Eeuo pipefail
    install.cargo cargo-update || true
    cargo install-update -a
)
f.x cargo.update.all

sourced



