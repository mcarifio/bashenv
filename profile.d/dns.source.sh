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




