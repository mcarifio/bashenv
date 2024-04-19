source /etc/bashrc

&> /dev/null bashenv.loaded || source ~/.bash_profile

# run all bashenv functions of the form ${something}.session.
bashenv.session.start
