# haskell stack

path.add.all $(find $(stack path --stack-root) -type d -name bin)
__bashenv_stack.bashrc() { source <(stack --bash-completion-script stack); }
declare -fx __bashenv_stack.bashrc
__bashenv_stack.bashrc

