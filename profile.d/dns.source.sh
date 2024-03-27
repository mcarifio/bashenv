# usage: [guard | source] dns.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        u.bad "${BASH_SOURCE} --install # not implemented"
    fi
fi


dns.zone() (
    : '${tld}'
    local -r _tld=${1:?'expecting a tld, e.g. carif.io or mg8702'}
    # dig zonefile and parse
    # arp the lan
    # mdns query
    # take the set union
    echo 'tbs'a
)
f.complete dns.zone


dns.resolve.all() (
    local -r _dn=${1:?'expecting a domain name'}
    for _resolver in $(grep nameserver /etc/resolv.conf | awk '{print $2;}'); do
	(set -x; dig +short @${_resolver} ${_dn})
    done
)
f.complete dns.resolve.all

loaded "${BASH_SOURCE}"


