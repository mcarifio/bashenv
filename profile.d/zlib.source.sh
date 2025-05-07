# ${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

zlib.root() (
    : '[${_folder}...] # return the first folder that actually exists or '
    path.folder {/run,}/media/${USER}/mobilehome/${USER}/Documents/e ${HOME}/Documents/e
)
f.x zlib.root

zlib.category() (
    : '${pathname} # |> returns the category of a pathname, e.g. foo.rs.pdf.xz returns rs'
    local _one="${1:?'expecting a pathname'}"
    # remove dirname
    _one=${_one%%*/}
    # turn basename parts into an array. 0 is basename, 1 is category.
    declare -a _cat=( ${_one//./ } )
    (( ${#_cat[@]} > 2 )) && echo ${_cat[1]};
)
f.x zlib.category

zlib.category.pathname() (
    set -Eeuo pipefail
    local _cat=${1:?'expecting a category'}
    local _root=${2:-$(zlib.root)}
    find ${_root} \( -type d -o -type l -xtype d \) -name ${_cat}
)
f.x zlib.category.pathname

zlib.category.missing() (
    local -a _args=( "$@" ); [[ -z "${_args}" ]] && _args=( $(zlib.files .) )
    for _src in ${_args[@]}; do
        local _cat=$(zlib.category ${_src})
        [[ -z "${_cat}" ]] && { continue; }
        local _pn=$(zlib.category.pathname ${_cat})
        [[ -z "${_pn}" ]] && { echo "${_cat}"; }
    done | sort | uniq
)
f.x zlib.category.missing


zlib.categorize.folder() (
    set -Eeuo pipefail
    local _folder="${1:-${PWD}}"
    local _category="${2:-$(u.folder ${_folder})}"
    for f in  $(find "${_folder}" -name \*.pdf || -name \*.epub ! -name \*.${_category}.*); do
        mv -v "$f" "${f%%.*}.${_category}.${f##*.}"
    done
)
f.x zlib.categorize.folder

function zlib.compressed? (
    : 'zlib.is-compressed ${pathname} # sets $? to 0 iff ${pathname} is compressed'
    file -b ${1?'expecting a pathname'} | grep --quiet 'compressed data'
)
f.x zlib.compressed?

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
f.x zlib.format


zlib.target() (
    : 'zlib.target ${explicit} ${src} [[${_prefix}] ${_notfound}] # zlib.target foo.rs.pdf.xz #  mv foo.rs.pdf.xz to ~/Documents/e/pl/rs'
    # Skip pathnames with whitespace or punctuation.
    [[ "$1" =~ [[:space:]] ]] && return $(u.error "'$1' contains whitespace, skipping...")
    [[ "$1" =~ [\!\"\#\$\%\&\'\(\)\*\+\,\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~] ]] && return $(u.error "'$1' contains unwanted characters, skipping...")
    # echo the explicit name if it's stated
    [[ -n "$1" ]] && { echo "$1"; return 0; }
    # otherwise generate the target from ${src}
    # map the category to a directory name e.g. .rs.pdf => ~/Document/e/pl/rs
    local _category=$(zlib.category "${2:?'expecting a pathname'}")
    local _prefix="${3:-$(zlib.root)}"
    # local _notfound="${4:-${PWD}}"
    local _notfound="${4:-2sort/${_category}}"
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
f.x zlib.target

zlib.rename.pdf() (
    : '${_category} *.pdf'
    local _category=${1:?"${FUNCNAME} expecting a category"}; shift
    for _pathname in "$*"; do
        local _title="$(pdf.title "${_pathname}")"
        [[ -n "${_title}" ]] || return $(u.error "No title for ${_pathname}")
        local _lastname="$(pdf.author.lastname "${_pathname}")"
        [[ -n "${_lastname}" && unknown != "${_lastname}" ]] || return $(u.error "No author lastname for ${_pathname}")
        local _year="$(pdf.creationdate "${_pathname}")"
        [[ -n "${_year}" ]] || return $(u.error "No year for ${_pathname}")
            
        local _suffix="${_pathname#*.}"
        local _folder="$(dirname "${_pathname}")"
        mv -v "${_pathname}" "${_folder}/${_title}-${_lastname}-${_year}.${_category}.${_suffix}"
    done
)



zlib.mv() (
    : 'zlib.mv ${_src} [${_target}] # mv src to target. default target is ~/Documents/e/2sort'
    local _pathname="${1:?'expecting a pathname'}"

    # Skip pathnames with whitespace or punctuation.
    [[ "${_pathname}" =~ [[:space:]] ]] && return $(u.error "'${_pathname}' contains whitespace, skipping...")
    [[ "${_pathname}" =~ [\!\"\#\$\%\&\'\(\)\*\+\,\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~] ]] && return $(u.error "'${_pathname}' contains unwanted characters, skipping...")

    # uncompleted zlibrary downloads have a *.part working file which is removed on completion.
    # skip uncompleted downloads
    local _part="$(echo ${_pathname}.*.part)"
    [[ -f "${_part}" ]] && return $(u.error "${_part} indicates ${_pathname} download not complete, skipping...")
    mv "${_src}" $(zlib.target "${2:-''}" "${1:?'expecting a pathname'}")
)
f.x zlib.mv

zlib.files() (
    # recursive at root
    find ${1:-.} -type f -name \*.\*.epub -o -name \*.\*.pdf ! -path '* *'
)
f.x zlib.files

zlib.mv.all() (
    : 'zlib.mv.all *.*.{pdf,epub} # mv all matching pathnames to a target based on the pathname "category"'
    # _args, the command line arguments. Defaults to *.pdf *.epub
    local -a _args=( "$@" ); [[ -z "${_args}" ]] && _args=( $(zlib.files .) )
    for _src in ${_args[@]}; do
        # skip partial downloads
        local _part=$(echo $(dirname "${_src}")/$(path.basename "${_src}").*.${_ext}.part)
        [[ -r  "${_part}" ]] && continue
        zlib.mv "${_src}" $(zlib.target '' "${_src}") || true
    done
)
f.x zlib.mv

zlib.mv.tor() (
    zlib.mv.all "~/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/Downloads/*.{epub,pdf}"
)
f.x zlib.mv.tor

zlib.rename.catpat() (
    for _ext in pdf epub; do
        rename .${_ext} .${1:?'expecting a category'}.${_ext} ${2:?'expecting a glob'}*.${_ext}
    done
)
f.x zlib.rename.catpat

zlib.rename() (
    ${FUNCNAME}.catpat ${1:?'expecting a category'} *$1-
)
f.x zlib.rename

e.locate.regenerate() (
    set -Eeuo pipefail
    local _db="${1:-$(zlib.root)/${FUNCNAME%.*}.db}"
    >&2 printf "${FUNCNAME} regenerating '${_db}'... "
    sudo updatedb --require-visibility yes --add-prunenames '2sort 2sort-manually .attic' --output "${_db}" --database-root "${_db%/*}"
    sudo chown ${USER}:${USER} "${_db}"
    >&2 echo done
)
f.x e.locate.regenerate

u.young() (
    local _pn="${1:?'expecting a pathname'}"
    local -i _threshold=${2:-$(( 7 * 24 * 60 * 60 ))} # default 1 week
    [[ -e "${_pn}" ]] || return $(u.error "'${_pn}' not found")
    local -i _now=$(date +%s) _mod=$(stat -c %Y -- "${_pn}")
    (( ( _now - _mod ) < _threshold ))
)


e.locate() (
    set -Eeuo pipefail
    local _db="$(zlib.root)/${FUNCNAME}.db"
    # declare -p _db
    # TODO mcarifio: regenerate if _db is "too old"
    u.young "${_db}" || ${FUNCNAME}.regenerate "${_db}"
    locate --database "${_db}" "$@"    
)
f.x e.locate

e.locate.ac() (
    set -Eeuo pipefail
    ${FUNCNAME%.*} -r -- $(printf -- '-%s-[[:digit:]][[:digit:]][[:digit:]][[:digit:]]\.%s\.' ${1:?'[^-]*'} ${2:-'[^\.]*'})
)
f.x e.locate.ac


zlib.env() {
    e.locate.regenerate
}
f.x zlib.env

sourced || true
