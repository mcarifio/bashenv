# not really needed...

cat <<EOF > $(dirname ${BASH_SOURCE})/../../.envrc
source pj/bin/pj.sh
PATH_add pj/bin
EOF

direnv allow $(dirname ${BASH_SOURCE})/../..

