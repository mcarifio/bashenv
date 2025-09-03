#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob lastpipe
source $(u.here)/../$(path.basename.part $0 2).source.sh
declare gcc_version=15 clang_version=20 std=c++23
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) --pkg=g++-${gcc_version} --pkg=clang-${clang_version} --pkg=lld-${clang_version} || true
# post install
for exe in g{cc,++}-${gcc_version} clang{,++}-${clang_version}; do
    sudo update-alternatives --install /usr/bin/${exe%%-*} ${exe%%-*} /usr/bin/${exe} 50
done

# check the default versions
gcc --version
g++ --version
clang --version
clang++ --version

for c in {gcc,clang}; do
    ${c} -x c++ --std=${std} -E - < /dev/null > /dev/null || echo "${c} doesn't support '--std=${std}'?" >&2
done

