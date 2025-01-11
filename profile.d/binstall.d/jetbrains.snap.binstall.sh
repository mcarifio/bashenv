#!/usr/bin/env bash
set -Eeuo pipefail
for _s in clion datagrip goland intellij-idea-ultimate pycharm-professional rider rustrover webstorm; do
    $(u.here)/${_s}.snap.binstall.sh
done

