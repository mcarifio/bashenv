#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() (
    : '--pkg=${_pkg} # --pkg passed to binstalld.dispatch'
    set -Eeuo pipefail; shopt -s nullglob
    
    for _a in "${@}"; do
        case "${_a}" in
            --pkg=*) _pkg="${_a##*=}";;
            --) shift; break;;
            --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping" 1);; ## error on unknown switch
            *) break;;
        esac
        shift
    done

    # no default package list was passed
    (( #@ )) && return 0

    local _npm=$(rpm -ql ${_pkg} | grep -c 1 -E '\/bin\/npm$') || return $(u.error "${FUNCNAME} expecting npm to be installed with ${_pkg}, not found, stopping.")

    for _npm_pkg in $(path.contents.clean $@); do
        ${_npm} i -g "${_npm_pkg}" || true
    done
)

# see also nodejs.asdf.binstall.sh
_default_npm_packages=$(path.first "${ASDF_NPM_DEFAULT_PACKAGES_FILE}" \
                                   "${ASDF_DIR:-/nowhere}}/.default-npm-packages" \
                                   "$(home)/opt/asdf/current/.default-npm-packages)") || true
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --postinstall=post.install ${_default_npm_packages} "$@"


