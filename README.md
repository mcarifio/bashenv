# bashenv

A bash environment (that rests atop bash 5).

## Summary

We all have them. A set of personal utilities and scripts we've written to expedite our workflow(s) or just make our lives easier. Or maybe you've
gone all in with something like [oh my bash](https://github.com/ohmybash/oh-my-bash) and [gnu stow](https://github.com/aspiers/stow/) to -- you know --
manage your "symlink farms". Good stuff. Maybe better than this here. Bashenv is the middle ground, a little more machinery than hacking `~/.bash_profile` and
`~/.bashrc` but a little less than a plugin based ecosystem. Bashenv has only a few conventions and primatives to learn. 
Once you grok the pattern(s), it's easy to "bashenvify" some useful command, commit it to _your_ repo and then pull the changes whereever 
and whenever you need them. One fork, no pull requests (unless you're a good citizen, good for you) and off you go. You can even skip the fork if you like.

This README is divided into two parts, a <a href="#start">starting</a> part and a <a href="#usage">usage</a> part. 
If you want to use `bashenv` as the starting point for your own bash scripts, I recommend you <a href="#start-with-git">start with git</a>. 
You can then commit your changes and additions to your own repository, no coordination required. 
This is particularly useful if you work on several Linux machines at once. Make an improvement on one machine, commit the changes to your git repository and then 
git pull those improvements everywhere else.

If git gives you hives or you want something even simpler, <a href="#start-without-git">start without git</a>. 
A one-liner fetches a [a github snapshot](https://github.com/mcarifio/bashenv/archive/refs/heads/main.zip) into your directory of choice.


## <a id="start">Start</a>


In the directions below, I assume you're using `bash` 5 or better on a recent linux distro, for example [fedora](https://www.fedora.org/), [ubuntu](https://www.ubuntu.org/) or
(my new fav) [nixos](https://www.nixos.org/). This simplies the directions until I need something more elaborate or on other platforms (such as windows or mac).
I also assume github for the repository hosting and that you've mastered git and github authenication. (Which I haven't. When I know more I'll
update this document.) You can forego git. I don't recommend it. Bashenv is meant to be extended with _your_ stuff. Git makes that much easier.
But as long as you download `bashenv` to a directory, say `~/bashenv` and "hook it up" to your `~/.bash_profile` and `~/.bashrc` respectively,
you're good to go.

You start once (on a given host). After that, when you `cd` to the `bashenv` directory -- wherever it landed -- and `direnv` should re-establish your 
local dev environment. And if you don't like what `.envrc` does, adapt it or even turn it off with `direnv block ~/bashenv`. With the
sources, `bashenv` is yours.


## Context

Let's place the directions below in context:

```bash
export p=' '  ## a hack so you can cut an paste the sections below

$p grep -e '^ID' /etc/os-release ## ... I'm on fedora
ID=fedora

$p uname -a ## ... running a recent kernel
Linux spider 6.7.6-200.fc39.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Feb 23 18:27:29 UTC 2024 x86_64 GNU/Linux

$p id  ## ... as the default user 1000
uid=1000(mcarifio) gid=1000(mcarifio) groups=1000(mcarifio),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

$p echo $BASH_VERSION ## ... with a recent bash
5.2.26(1)-release

$p stat ~/bashenv ## ... and no local ~/bashenv
stat: cannot statx '~/bashenv': No such file or directory
```

I'm synthesizing these instructions on fedora 39, logged in as user `mcarifio` within bash 5.2 with the intent of putting `${USER}`'s `bashenv` in `~/bashenv`. 
You'll have to do some on-the-fly mental gymnastics if your local box varies significantly from this.
You need to have some local commands installed using your preferred means: git, gh, realpath, bash of course and so forth.
For example, here's `git` installed via `dnf`. 

```bash
$p rpm -q git  ## sudo dnf install -y git
git-2.44.0-1.fc39.x86_64

$p type git  ## ... which is on PATH
git is hashed (/usr/bin/git)

$p git --version ## ... and will report it's own version.
git version 2.44.0

$p gh --version ## ... as will gh
gh version 2.43.1 (2024-02-05)
https://github.com/cli/cli/releases/tag/v2.43.1
```

I'll assume if you _do not_ have a command you can install it and put it on `PATH`. `${command} --version` is usually the quickest way to check, 
e.g `git --version` above. Of course, every Linux distro is just a little bit different on these details, so -- coward that I am -- 
I avoid the variance altogether and leave that exercise to the user. You should be a sudoer on the host with or without passwords.

To make it a little easier to install missing commands, define this helper function `dnf.install`:

```bash
dnf.install() (
	local _missing=''
	for _a in "$@"; do type -p &> /dev/null $_a || _missing+=" ${_a}"; done
	[[ -z "${_missing}" ]] && return 0
	sudo dnf upgrade -y --refresh
	sudo dnf install -y ${_missing}
)
```



### <a id="start-with-git">Start With Git</a>

Install `git` and friends:

```bash
dnf.install git{,-extras} gh
```

Fork `bashenv` so you can customize your fork later and clone the fork. I'll use [`gh`](https://cli.github.com/manual/) for that:

```bash
$p gh auth login ## auth ${USER} to github
$p gh repo fork https://github.com/mcarifio/bashenv --remote --clone --upstream-remote-name ## ... from ${HOME}
$p cd bashenv ## ... creating ~/bashenv and positioning to it
```

### <a id="start-without-git">Start Without Git</a>

Install `unzip`, `bsdtar` and `curl`:

```bash
dnf.install unzip bsdtar curl
```

Then download and unzip `bashenv` to `~/bashenv` utilizing a bash helper function `unzip.url`:
```bash
unzip.url() ( curl -sSL  ${1:?'url?'} | bsdtar -C /tmp -xf - && mv -v /tmp/bashenv-main ${2:-~/bashenv}; )
unzip.url https://github.com/mcarifio/bashenv/archive/refs/heads/main.zip
```

### Post Download

At this point you have populated `~/bashenv` with bash scripts. Time to install any addition packages `bashenv` needs and then
customize `~/.bash_profile` and `~/.bashrc` respectively.

Install the additional supporting command line tools using the means you prefer, for example:

```bash
dnf.install direnv tree just
```

Alternatively:

```bash
pj/bin/start.sh
```

I recommend `direnv` to organize your programming environment. Enable it:
```bash
direnv allow ~/bashenv
```

## Project Layout

The project layout consists of two parts: the "project" part `pj/` and the actual content of `bashenv` in `.bash_profile.d/**`.
The scripts in `~/bashenv/.bash_profile.d` are sourced (or guarded, more on that below) to define a set of bash functions.
This includes creating a `${something}.session` function which `~/.bashrc` will eventually call. 

The project "support" is by folder, e.g. `pj/bin` has
local scripts like `start.sh` and `pj`. You can add your scripts there as well.

The files in `.bash_profile.d/**` follow a naming convention.
`${file}.source.sh` is always sourced. `${command}.guard.sh` is sourced depending on the "guard". For example, `git.guard.sh` is only sourced if the command `git` is in the PATH.
Otherwise it's silently skipped. You can think of `*.guard.sh` as the set union of what you might have on your machine and is used only if it's actually installed.
You can always `source ${file}.guard.sh`. The guard is then bypassed.

Each `${command}.{guard,source}.sh` file will define an exported function `${command}.session`, for example `git.session`. This function is called by `session.start()` and
does what `.bashrc` would do. Generally this includes sourcing function definitions that are _not_ exported and binding `readline` functions. Making these functions makes it easy to
to replay what `.bashrc` would do. It's also helpful to customize a command all in a single file, e.g. `git.guard.sh`. 

These conventions are a work in progress and subject to change. But understanding the layout aids navigation and use. Basically you're buying into a slew of global, exported functions loaded when you start a login shell. These functions are all exported to subshells. Some of the functions follow patterns for later use such as `${command}.session`. But
the conventions are simple and frankly promote a copy-and-adapt style. 

## Hacking

I use emacs. You should use what suits you. But it should be emacs.

## More

* [pj/doc/README.md](pj/doc/README.md) is the entry into the documentation.
* [pj/doc/todo.md](pj/doc/todo.md) lists action items and questions.




## <a id="usage">Usage</a>

You're through the hard part. Using bashenv is easy. When you create a login session in bash, bash sources `~/.bash_profile`. When you create a new shell, bash sources `~/.bashrc`.
A login session is also a new shell, therefore your source both.

Bashenv traffics in bash functions which are all loaded from `~/bashenv/.bash_profiled.d/**.sh`. Bash functions are underappreciated and underutilized. In particular,
just like environment variables they can be exported and therefore visible to all subshells without redefinion or reloading. You can, of course, load a new definition for the same name in subshell. But generally there's little need.

Because you have to explicitly export a function after defining it using the exotic `declare -fx ${function}`, functions are often sourced (and sourced again and again and again) via `~/.bashrc`. With just an extra declaration this is completely unnecessary. You can have convenience _and_ start subshells quickly with bashenv. (But really with just judicious use of bash.)

### <a id="usage-without-git">Usage Without Git</a>

Set aside your existing `~/.bash_profile` and `~/.bashrc` in `~/.bashenv-recover` and then link to `bashenv/.bash_profile` and `bashenv/.bashrc` respectively:

```bash
mkdir -p ~/.bashenv-recover
mv -v ~/.bash_profile ~/.bashrc ~/.bashenv-recover
ln -srf ~/bashenv/.bash_profile
ln -srf ~/bashenv/.bashrc
```

You're done! You have bashenv on your next bash login session. To get it immediately: `source ~/.bash_profile && source ~/.bashrc`

### <a id="usage-with-git">Usage With Git</a>

Usage with git is configured like usage without git; you just did it above.

With git however you can add or modify bashenv scripts, commit the changes, push the changes and pull them to other machines.

## RAQ (Randomly Asked Questions)

* Question: There are better shells to invest in, e.g. `zsh`, `elvish`, `xonsh`, `nushell` and so forth. Why bother with this? 
  Answer: Bash is usually the default shell and you'll land in it often. A few simple patterns go a long, long way. 
  But yes, bash is imperfect as a shell _and_ as a programming language. But it's ubiquitious.
  
* Question: If I'm going to start automating things, bash is the wrong language. 
  Answer: Busted again. Except that I've noticed that I can whip up a quick bash function to automate something in about 5 minutes. Especially if a I start with a bash function that is similar or close. 
  And I can give that function a name that makes sense to me, that I can remember and
  that the bash shell will help complete when my memory is hazy. Which is about 10 minutes after researching some new command.
  
* Question: Unneccessary. Use bash history. Answer: Yes, but this isn't either/or. The functions I've tended to write fall into a few patterns:
  + I change the default arguments to a command
  + I contextualize arguments to a command
  + I bash complete a command differently from the original authors.
  + I immortalize one liners.
  + I bulletproof chatgpt answers.
  + I avoid confusing bash constructs like regular expression matching using `=~`. I can stop googling `awk match`.
  
  




