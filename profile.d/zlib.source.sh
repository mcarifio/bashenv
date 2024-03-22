zlib.category() (
    : '${pathname} # |> returns the category of a pathname, e.g. foo.rs.pdf.xz returns rs'
    local _one="${1:?'expecting a pathname'}"
    # remove dirname
    _one=${_one%%*/}
    # turn basename parts into an array. 0 is basename, 1 is category.
    declare -a _cat=( ${_one//./ } )
    (( ${#_cat[@]} > 2 )) && echo ${_cat[1]};
)
f.complete zlib.category


zlib.categorize.folder() (
    set -Eeuo pipefail
    local _folder="${1:-${PWD}}"
    local _category="${2:-$(u.folder ${_folder})}"
    for f in  $(find "${_folder}" -name \*.pdf || -name \*.epub ! -name \*.${_category}.*); do
        mv -v "$f" "${f%%.*}.${_category}.${f##*.}"
    done
)
f.complete zlib.categorize.folder

function zlib.compressed? (
    : 'zlib.is-compressed ${pathname} # sets $? to 0 iff ${pathname} is compressed'
    file -b ${1?'expecting a pathname'} | grep --quiet 'compressed data'
)
f.complete zlib.compressed?

zlib.format() (
    : 'zlib.format ${pathname} # |> returns the category of a pathname, e.g. foo.rs.pdf.xz returns pdf, foo.pdf returns pdf'
    local _one="${1:?'expecting a pathname'}"
    # remove dirname
    _one=${_one%%*/}
    # turn basename parts into an array. 0 is basename, 1 is category, 2 is format
    declare -a _cat=( ${_one//./ } )
    declare -i _len=${#_cat[@]}
    (( ${_len} == 2 )) && echo ${_cat[1]}
    (( ${_len} > 2 )) && echo ${_cat[2]}
)
f.complete zlib.format


zlib.target() (
    : 'zlib.target ${explicit} ${src} [[${_prefix}] ${_notfound}] # zlib.target foo.rs.pdf.xz #  mv foo.rs.pdf.xz to ~/Documents/e/pl/rs'
    # echo the explicit name if it's stated
    [[ -n "$1" ]] && { echo "$1"; return 0; }
    # otherwise generate the target from ${src}
    # map the category to a directory name e.g. .rs.pdf => ~/Document/e/pl/rs
    local _category=$(zlib.category "${2:?'expecting a pathname'}")
    local _prefix="${3:-${HOME}/Documents/e}"
    # local _notfound="${4:-2sort/${_category}}"
    local _notfound="${4:-${PWD}}"
    if [[ -n "${_category}" ]]; then
	# Find the first subdirectory under ${_prefix} named ${_category}. That's the target.
	local _target=$( 2>/dev/null find "${_prefix}" -name "${_category}" -type d -print -quit )
        [[ -z "${_target}" ]] && _target=$( 2>/dev/null find "${_prefix}" -name "${_category}" -type l -xtype d -print -quit )
	# Find the target? Print it. Otherwise print the default, a directory with names to be sorted.
	if [[ -n "${_target}" ]] ; then
	    echo "${_target}"
	else
	    local _folder="${_prefix}/${_notfound}"
	    [[ -d "${_folder}" ]] || mkdir -p "${_folder}"
            >&2 echo "${_category} not yet in ${_prefix}, skipping..."
	    echo "${_folder}"
	fi	
    else
	# No category found therefore no way to deduce the target.
	>&2 echo "No category found in '$2', e.g. something like .rs.pdf"
	return 1
    fi    
)
f.complete zlib.target


zlib.mv() (
    : 'zlib.mv ${_src} [${_target}] # mv src to target. default target is ~/Documents/e/2sort'
    local _pathname="${1:?'expecting a pathname'}"

    # uncompleted zlibrary downloads have a *.part working file which is removed on completion.
    # skip uncompleted downloads
    local _part="$(echo ${_pathname}.*.part)"
    [[ -f "${_part}" ]] && return $(u.error "${_part} indicates ${_pathname} download not complete, skipping...")
    mv -v "${_src}" $(zlib.target "${2:-''}" "${1:?'expecting a pathname'}")
)
f.complete zlib.mv

zlib.mv.all() (
    : 'zlib.mv-all *.{pdf,epub} # mv all matching pathnames to a target based on the pathname "category"'
    for _src in "$@"; do mv -v "${_src}" $(zlib.target '' "${_src}") || true ; done
)
f.complete zlib.mv

zlib.categorize.all() (
    local _category=${1:?'expecting a category'}; shift
    for _f in "$@"; do
	_src=${_f%%*/}
	declare -a _parts=( ${_src//./ } )
	local -i _start=1
	(( ${#_parts[@]} > 2 )) && _start=2
	local _type=${_parts[1]}
	[[ ${_type} != pdf && ${_type} != epub ]] && continue
	local _target=${_parts[0]}.${_category}$(printf '.%s' ${_parts[@]:${_start}})
	mv -v ${_f} ${_target}
    done
)
f.complete zlib.categorize.all
