# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        case "$(os-release.id)" in
            fedora) dnf install erlang{,-rebar3};;
            ubuntu) sudo command apt install -y erlang{,-rebar3};;
            *) u.bad "${BASH_SOURCE} --install unknown for $(os-release.id)"
        esac
        git clone git clone https://github.com/gleam-lang/gleam.git ~/src/gleam
        cd ~/srg/gleam
        make install ## assumes cargo on PATH
        gleam --version
    fi
fi

loaded "${BASH_SOURCE}"
