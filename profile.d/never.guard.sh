>&2 echo "${BASH_SOURCE} should never be guarded."
u.have ${BASH_SOURCE%%.guard.sh}

loaded "${BASH_SOURCE}"
