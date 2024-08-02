#!/usr/bin/env bash
set -Eeuo pipefail

# ${guard}.install.sh will install ${guard} in various ways. You'll choose and
# then customize the one you want, typically by modifying `install()` to call
# the right helper function, e.g. `glab.install.sh` calls bash function `install()`
# which calls `install.asdf()`. It's a little crufty with all the boilerplate,
# but the script and functions are short.

# install {_template,${guard}}.install.sh


# install() ( install.$(os.release ID) "$@"; )
install() (
    install.$(os.release ID) "$@"
    install.check "$1"
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
install $(path.basename ${BASH_SOURCE}) "$@"

