#!/usr/bin/env bash
# set -x
set -Eeuo pipefail; shopt -s nullglob

# on.return() { local -i _status=$?; printf '* => %s *\n' ${_status} >&2; return ${_status}; }
# trap on.return RETURN

source $(u.here)/options.source.sh

# set -x
# exit 1

    
all() (
    set +Ee
    set -uo pipefail; shopt -s nullglob
    # succeeds
    local _result=''; _result=$(example.options no options ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool just bool  ${LINENO}}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --do=something just something else ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --var=${USER} just var ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --varo=oh just varo ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --many=1 --varo=oh --many=2 --many=3 just varo ${LINENO})
    test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --pairs=two:2 --varo=oh --pairs=one:1 just varo ${LINENO})
    test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2    
    _result=''; _result=$(example.options --pairs=one:two:three --varo=oh just varo ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    

    # fails
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}" || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}"  || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}"  || echo "failed ${LINENO}" >&2
    
    # succeeds
    _result=''; _result=$(example.options --var=100 --bool --do=something+else --varo=200 --doo=dowhop all options ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool -- --var=100 short circuit  ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
)

all
