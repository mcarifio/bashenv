source $(dirname ${BASH_SOURCE})/pj.sh

cat <<EOF > $(pj.root)/.envrc
# created by $(realpath ${BASH_SOURCE}) on '$(date)'
source pj/bin/pj.sh
PATH_add pj/bin
EOF

direnv allow $(pj.root)
