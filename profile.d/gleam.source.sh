gleam.install() (
    : '#> install gleam in '
    dnf install erlang{,-rebar3}
    git clone git clone https://github.com/gleam-lang/gleam.git ~/src/gleam
    cd ~/srg/gleam
    make install ## assumes cargo on PATH
    gleam --version
)
declare -fx gleam.install

