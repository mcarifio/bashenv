# bashenv

A bash environment (that rests atop bash).

## summary

We all have them. A set of personal utilities and scripts we've written to expedite our workflow(s) or just make our lives easier. Or maybe you've
gone all in with something like [oh my bash](https://github.com/ohmybash/oh-my-bash) and [gnu stow](https://github.com/aspiers/stow/) to -- you know --
manage your "symlink farms". Good stuff. Maybe better than this here. Bashenv is the middle ground, a little more than hacking `~/.bash_profile` and
`~/.bashrc` but a little less than a plugin based system. There are only a few conventions and primatives to learn. Once you grok the pattern(s),
it's easy to "bashenvify" some useful command, commit it to _your_ repo and then pull the changes whereever and whenever you need them. One fork,
no pull requests (unless you're a good citizen, good for you) and off you go.


## start

In the directions below, I assume you're using `bash` 5 or better on a recent linux distro, for example [fedora](https://www.fedora.org/), [ubuntu]() or
(my new fav) [nixos](). This simplies the directions until I need something more elaborate or on other platforms (such as windows or mac).
I also assume github for the repository hosting and that you've mastered git and github authenication. (Which I haven't. When I know more I'll
update this document.)

You start once. After that, when you `cd` to the `GIT_DIR`, `direnv` should re-establish your local working environment.

Let's place the directions below in context:

```bash
mcarifio@spider:~/bashenv$p grep -e '^ID' /etc/os-release ## ... I'm on fedora
ID=fedora

mcarifio@spider:~/bashenv$p uname -a ## ... running a recent kernel
Linux spider 6.7.6-200.fc39.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Feb 23 18:27:29 UTC 2024 x86_64 GNU/Linux

mcarifio@spider:~/bashenv$p id  ## ... as the default user 1000
uid=1000(mcarifio) gid=1000(mcarifio) groups=1000(mcarifio),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

mcarifio@spider:~/bashenv$p echo $BASH_VERSION ## ... with a recent bash
5.2.26(1)-release

mcarifio@spider:~/bashenv$p stat ~/bashenv ## ... and no local ~/bashenv
stat: cannot statx '~/bashenv': No such file or directory
```

You have some local commands installed using your preferred means: git, gh, etc.

```bash
carifio@spider:~/bashenv$p rpm -q git
git-2.44.0-1.fc39.x86_64
mcarifio@spider:~/bashenv$p type git
git is hashed (/usr/bin/git)
mcarifio@spider:~/bashenv$p git --version
git version 2.44.0


```



Fork `bashenv` so you can customize your fork later. I'll use `gh` for that. 

```bash
$ export p=' '
$p 
$p git clone https://github.com/${top} ${top} && cd ${top}
```

Install the supporting command line tools using the means you prefer, for example:

```bash
sudo dnf install -y direnv tree just
```
Alternatively:
```bash
sudo pj/bin/start.sh prerequisites
```


Check that you have the appropriate prerequisites:

```bash
(pj/bin/start.sh ckprerequisites || >&2 echo -e "\nNOT OK\n") || tee pj/log/ckprerequisites.log 
```
If you see `NOT OK`, read `pj/log/ckprerequsites.log` and fix what it suggests. 
This will be the most brittle part of the starting process.

I recommend `direnv` to organize your programming environment. Populate an `.envrc` file and `allow` it:
```bash
source pj/bin/mkenvrc
```

Finally confirm that you're good to go:
```bash
(start.sh doctor || >&2 echo -e "\nNOT OK\n") || tee pj/log/doctor.log
```
If you see `NOT OK`, read `pj/log/doctor.log` and fix what it suggests. 

## project layout

The project layout consists of two parts: the "project" part `pj/` and the actually content of `tysh` in `src`. The project "support" is by folder, e.g. `pj/bin` has
local scripts like `start.sh` and `pj`. You can add your scripts there as well. Here's the annotated layout:

```bash
$p tree -aF -I '.git*' -I '#*#' -I '.#*'  ## annotations are added manually like this; they're not part of the command output
./
├── LICENSE
├── pj/ ## the project
│   ├── bin/ ## scripts
│   │   ├── pj* 
│   │   └── start.sh*
│   ├── doc/ ## documentation
│   │   ├── README.md
│   │   └── todo.md
│   ├── log/ ## example logs for comparison
│   └── template/ ## starting points for your code
│       ├── .envrc ## starting point for .envrc used by `pj/bin/start.sh envrc`
│       └── script.bash.sh* ## pj/template/script.bash.sh is the starting point for a bash script
├── README.md ## you are here
└── bashenv/
```

The layout is a work in progress and subject to change. But understanding the layout aids navigation.

## hacking

I use emacs. You should use what suits you.

## more

* [pj/doc/README.md](pj/doc/README.md) is the entry into the documentation.
* [pj/doc/todo.md](pj/doc/todo.md) lists action items and questions.



