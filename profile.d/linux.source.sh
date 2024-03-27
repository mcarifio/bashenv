# linux.modules() { find /lib/modules -type f -regex '\.ko(\.xz)?$'; } # regex is broken
linux.modules() (
    find /lib/modules -type f -name '*.ko'
    find /lib/modules -type f -name '*.ko.xz'
)
f.complete linux.modules

module.is-signed() (
    local _pn=${1:?'expecting a pathname'}
    case "${_pn}" in
        *.ko.xz) xzcat ${_pn};;
        *.ko) cat ${_pn};;        
    esac | grep -qF '~Module signature appended~'
)
f.complete module.is-signed

linux.modules.signed() (
    for m in $(linux.modules); do
	module.is-signed $m && echo "$m signed" || echo "$m unsigned"
    done
)
f.complete linux.modules.signed

loaded "${BASH_SOURCE}"

