${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

cursor.list-extensions() ( jq -r '.publisher + "." + .name' ~/.cursor/extensions/*/package.json; )
f.x cursor.list-extensions

cursor.install-extension() (
  local _slug="${1:?"${FUNCNAME} missing _slug"}"
  local _publisher _extension _version _vsix_url _tmpfile
  local _name _dest _existing_version

  if [[ ! "$_slug" =~ ^([^/@]+)/([^@]+)(@(.+))?$ ]]; then
    echo "❌ Invalid format. Use publisher/extension[@version]" >&2
    return 1
  fi

  _publisher="${BASH_REMATCH[1]}"
  _extension="${BASH_REMATCH[2]}"
  _version="${BASH_REMATCH[4]}"

  if [[ -z "$_version" ]]; then
    _version=$(curl -fsSL "https://open-vsx.org/api/$_publisher/$_extension/latest" | jq -r '.version')
    if [[ -z "$_version" || "$_version" == "null" ]]; then
      echo "❌ Failed to resolve latest version for $_publisher/$_extension" >&2
      return 1
    fi
  fi

  _vsix_url="https://open-vsx.org/vsix/$_publisher/$_extension/$_version"
  _tmpfile="$(mktemp --suffix=.vsix)"

  echo "🌐 Downloading $_slug@$_version from Open VSX..."
  if ! curl -fsSL "$_vsix_url" -o "$_tmpfile"; then
    echo "❌ Failed to download VSIX from: $_vsix_url" >&2
    return 1
  fi

  _name=$(unzip -p "$_tmpfile" extension/package.json | jq -r '.publisher + "." + .name')
  if [[ -z "$_name" || "$_name" == "null.null" ]]; then
    echo "❌ Failed to extract extension name from VSIX" >&2
    rm -f "$_tmpfile"
    return 1
  fi

  _dest="$HOME/.cursor/extensions/$_name"
  if [[ -f "$_dest/extension/package.json" ]]; then
    _existing_version=$(jq -r '.version' < "$_dest/extension/package.json")
    if [[ "$_existing_version" == "$_version" ]]; then
      echo "✅ $_name@$version is already installed. Skipping."
      rm -f "$_tmpfile"
      return 0
    else
      echo "🔁 Upgrading $_name from $_existing_version → $_version"
      rm -rf "$_dest"
    fi
  else
    echo "📦 Installing $_name@$_version"
  fi

  mkdir -p "$_dest"
  unzip -q "$_tmpfile" -d "$_dest"
  rm -f "$_tmpfile"

  echo "✅ Installed $_name@$_version → $_dest"
  echo "🔄 Restart Cursor to activate."
)
f.x cursor.install-extension


cursor.doc.urls() (
    local -A _urls=(
        [start]=""
        [doc]=""
        [vcs]=""
        [blog]=""
        [irc]=""
    )
    echo ${_urls[${1:-@}]}
)
f.x cursor.doc.urls

cursor.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x cursor.doc

cursor.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x cursor.env

cursor.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x cursor.session

cursor.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x cursor.installer

cursor.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x cursor.config.dir

cursor.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x cursor.config


sourced || true
