# ${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

#---
# pdf.mv() {
#     # if [[ -r "$1" ]]; then
#     #   >&2 printf "'%s' not found\n" "$1"
#     #   return 1
#     # fi
#     : pdf.mv ${_src} ${_location} [${_prefix}]
#     local _src="$1"
#     local _prefix="${2:-$(basename ${_src} .pdf)}"
#     local _location="${3:-${PWD}}"
#     local _date=$(pdf.creationdate "${_src}")
#     if [[ -z "${_date}" ]]; then
#         printf >&2 "no creation date found for %s\n" "${_src}"
#         return 1
#     fi

#     mv -v "${_src}" "$(md ${_location})/${_prefix}-${_date}.pdf"
# }
# f.x pdf.mv

# zlib.title() {
#     local _title=${1:?'expecting a pathname'}
#     _title=${_title%%---*}
#     if [[ "${_title}" =~ ^([^[[:punct:]]]+)$ ]]; then
#         _title=${BASH_REMATCH[1]}
#     fi
#     _title=${_title,,}
#     _title=${_title// /-}
#     echo ${_title}
# }
# f.x zlib.title

# zlib.lastname0() {
#     if [[ "$1" =~ [[:space:]]by[[:space:]][a-zA-Z]+[[:space:]]([a-zA-Z]+) ]]; then
#         echo ${BASH_REMATCH[1],,}
#     fi
# }

# # fix later
# zlib.lastname() {
#     local _pathname=${1:?'need a pathname'}
#     [[ -r "${_pathname}" ]] || {
#         echo >&2 "'${_pathname}' not readable."
#         return 1
#     }
#     local _result=$(pdf.author "${_pathname}" &>/dev/null) || true
#     [[ -n "${_lastname}" ]] && {
#         echo ${_lastname}
#         return 0
#     }
#     if [[ "${_pathname}" =~ ---([^[[:punct:]]+).*--- ]]; then
#         declare -a _name=(${BASH_REMATCH[1],,})
#         echo ${_name[-1]}
#     fi
# }

# zlib.date() {
#     local _pathname=${1:?'need a pathname'}
#     [[ -r "${_pathname}" ]] || {
#         echo >&2 "'${_pathname}' not readable."
#         return 1
#     }
#     local _result=$(pdf.creationdate "${_pathname}" &>/dev/null) || true
#     if [[ -n "${_result}" ]]; then
#         echo ${_result}
#     elif [[ "${_pathname}" =~ ---([[:digit:]]{4}) ]]; then
#         echo ${BASH_REMATCH[1],,}
#     fi
# }
# f.x zlib.date

# zlib.mv() (
#     # zlib.mv ${_src} ${_dir} [${_title} [${_lastname} [${_yyyy}]]]
#     # zlib.mv [--dir=pathname] [--title=prefix] [--author=name] [--date=yyyy] doc.{epub,pdf}

#     set -Eeuo pipefail
#     local _dir="${PWD}" _title="" _lastname="" _date=""
#     if ((${#@})); then
#         for _a in "${@}"; do
#             case "${_a}" in
#             --dir=*) _dir="${_a#--dir=}" ;;
#             --title=*) _title="${_a#--title=}" ;;
#             --lastname=*) _lastname="${_a#--lastname=}" ;;
#             --date=*) _date="${_a#--date=}" ;;
#             --)
#                 shift
#                 break
#                 ;;
#             *) break ;;
#             esac
#             shift
#         done
#     fi

#     local _src="${1:?'expecting a file name'}"
#     [[ -e "${_src}" ]] || {
#         echo >&2 "${_src} not found"
#         return 1
#     }

#     [[ -e "${_dir}" && ! -d "${_dir}" ]] && {
#         echo >&2 "${_dir} is a file"
#         return 1
#     }
#     [[ ! -d "${_dir}" ]] && {
#         echo >&2 "${_dir} does not exist"
#         return 1
#     }
#     [[ -z "${_title}" ]] && _title=$(zlib.title "${_src}")
#     [[ -z "${_lastname}" ]] && _lastname=$(zlib.lastname "${_src}")
#     [[ -z "${_date}" ]] && _date=$(zlib.date "${_src}")
#     local _ext=${_src##*.}
#     local _dest="${_dir}/${_title}-${_lastname}-${_date}.${_ext}"

#     if [[ "${_ext}" = pdf ]]; then
#         mv "${_src}" "${_dest}"
#         xz "${_dest}"
#         echo >&2 "${_dest}"
#     else
#         mv "${_src}" "${_dest}"
#         echo >&2 "${_dest}"
#     fi
# )
# f.x zlib.mv

#---




zlib.root() (
    : '[${_folder}...] # return the first folder that actually exists or '
    f.folder ${@:-/run/media/${USER}/home/${USER}/Documents/e ${HOME}/Documents/e}; )
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
    find ${_root} -type d -name ${_cat}    
)
f.x zlib.category.pathname

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
    mv -v "${_src}" $(zlib.target "${2:-''}" "${1:?'expecting a pathname'}")
)
f.x zlib.mv

zlib.mv.all() (
    : 'zlib.mv-all *.{pdf,epub} # mv all matching pathnames to a target based on the pathname "category"'
    # _args, the command line arguments. Defaults to *.pdf *.epub
    local -a _args=( "$@" ); [[ -z "${_args}" ]] && _args=( $(find . -type f -name \*.epub -o -name \*.pdf ! -path '* *') )
    for _src in ${_args[@]}; do
        # skip partial downloads
        local _part=$(echo $(dirname "${_src}")/$(path.basename "${_src}").*.${_ext}.part)
        [[ -r  "${_part}" ]] && continue
        zlib.mv "${_src}" $(zlib.target '' "${_src}") || true
    done
)
f.x zlib.mv

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
f.x zlib.categorize.all

zlib.cat.tree() (
    : '${_root:-$PWD} # add/change the suffix of every .pdf/.epub file in a tree to match its directory'
    # foo/something.bar.pdf -> foo/something.foo.pdf
    for _f in $(find ${1:-${PWD}} -type f -name \*.pdf -o -name \*.epub); do
        local _cat=$(basename $(dirname ${_f}))
	local _src=${_f%%*/}
	declare -a _parts=( ${_src//./ } )
	local -i _start=1
	(( ${#_parts[@]} > 2 )) && _start=2
	local _type=${_parts[1]}
	local _target=${_parts[0]}.${_cat}$(printf '.%s' ${_parts[@]:${_start}})
	mv -v ${_f} "${_target}"
    done    
)
f.x zlib.cat.tree

zlib.env() { source <(mksearchable.sh --regenerate --function=fx --name=e.locate "$(zlib.root)"); }
f.x zlib.env

sourced || true
