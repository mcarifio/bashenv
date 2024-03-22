# bashenv

A low ceremony bash 5 environment for personal customizations. And a horrible summary.

## <a id="summary">Summary</a>

We all have them. A set of personal utilities and scripts we've written to expedite our workflow(s) or just make our lives easier. Or maybe you've
gone all in with something like [oh my bash](https://github.com/ohmybash/oh-my-bash) and [gnu stow](https://github.com/aspiers/stow/) to -- you know --
manage your "symlink farms". Good stuff. Maybe better than this here. Bashenv is the middle ground, a little more machinery than hacking `~/.bash_profile` and
`~/.bashrc` but a little less than a plugin based ecosystem. Bashenv has only a few conventions and primatives to learn. 
Once you grok the pattern(s), it's easy to "bashenvify" some useful command, commit it to _your_ repo and then pull the changes whereever 
and whenever you need them. One fork, no pull requests (unless you're a good citizen, good for you) and off you go. You can even skip the fork if you like.

This README is divided into two parts, a <a href="#start">starting</a> part and a <a href="#usage">usage</a> part. 
If you want to use `bashenv` as the starting point for your own bash scripts, I recommend you <a href="#start-with-git">start with git</a>. 
You can then commit your changes and additions to your own repository, no coordination required. 
This is particularly useful if you work on several Linux machines at once. Make an improvement on one machine, commit the changes to your git repository and then git pull those improvements everywhere else.

If git gives you hives or you want something even simpler, <a href="#start-without-git">start without git</a>. 
A one-liner fetches a [a github snapshot](https://github.com/mcarifio/bashenv/archive/refs/heads/main.zip) into your directory of choice.
You can then forego git _or_ you can control the sources using the tool of your choice (svn, mercurial, perforce, fossil, etc).


## <a id="start">Start</a>


In the directions below, I assume you're using `bash` 5 or better on a recent linux distro, for example [fedora](https://www.fedora.org/), [ubuntu](https://www.ubuntu.org/) or
(my new fav) [nixos](https://www.nixos.org/). This simplies the directions until I need something more elaborate or on other platforms (such as windows or mac).
I also assume github for the repository hosting and that you've mastered git and github authenication. (Which I haven't. When I know more I'll
update this document.) You can forego git. I don't recommend it. Bashenv is meant to be extended with _your_ stuff. Git makes that easier.
But as long as you download `bashenv` to a directory, say `~/bashenv` and "hook it up" to your `~/.bash_profile` and `~/.bashrc` respectively,
you're good to go.

You start once (on a given host). After that, when you `cd` to the `bashenv` directory -- wherever it landed -- and `direnv` should re-establish your 
local dev environment. And if you don't like what `.envrc` does, adapt it or even turn it off with `direnv block ~/bashenv`. With the
sources and some bash expertise, `bashenv` is yours.


## <a id="context">Context</a>

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

Following the bouncing command line above, you see that I'm synthesizing these instructions on fedora 39, 
logged in as user `mcarifio` within bash 5.2 with the intent of putting `${USER}`'s `bashenv` in `~/bashenv`. 
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

Alternatively, the [universal package tool (upt)](https://github.com/sigoden/upt/tree/main) can abstract away some installation details.
But you have to install it separately.


### <a id="start-with-git">Start With Git</a>

Install `git` and friends:

```bash
dnf.install git{,-extras} gh ## upt install -y git{,-extras} gh
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
dnf.install unzip bsdtar curl ## upt install -y unzip bsdtar curl 
```

Then download and unzip `bashenv` to `~/bashenv` utilizing a bash helper function `unzip.url`:
```bash
unzip.url() ( curl -sSL  ${1:?'url?'} | bsdtar -C /tmp -xf - && mv -v /tmp/bashenv-main ${2:-~/bashenv}; )
unzip.url https://github.com/mcarifio/bashenv/archive/refs/heads/main.zip
```

### <a id="post-download">Post Download</a>

At this point you have populated `~/bashenv` with bash scripts. Time to install any addition packages `bashenv` needs and then
customize `~/.bash_profile` and `~/.bashrc` respectively.

Install the additional supporting command line tools using the means you prefer, for example:

```bash
dnf.install direnv tree just ## upt install -y direnv tree just
```

Alternatively:

```bash
pj/bin/start.sh
```

I recommend `direnv` to organize your programming environment. Enable it:
```bash
direnv allow ~/bashenv
```

## <a id="project-layout-and-conventions">Project Layout and Conventions</a>

Bashenv's project layout consists of two parts: the "project" part `pj/` and the actual content of `bashenv` in `profile.d/**`.
The scripts in `~/bashenv/profile.d` are sourced (or "guarded", more on that below) to define a set of bash functions.
This includes creating a `${something}.session` function which `~/.bashrc` will eventually call. 

The project "support" is by folder, e.g. `pj/bin` has
local scripts like `start.sh` and `pj`. You can add your scripts there as well.
Generally nothing in `pj/**` is sourced by `.bash_profile` and `pj/bin` is not on `PATH` (except via `direnv`).

The files in `profile.d/**` are sourced by `~/.bash_profile` on login.
They define environment variables, add to `PATH` and define many exported bash functions.
The files follow a naming convention. `${file}.source.sh` files are always sourced.
`${command}.guard.sh` files are sourced depending on the "guard", the presence
of a command. For example, `git.guard.sh` is only sourced if the command `git` is on the PATH.
Otherwise it's silently skipped. You can think of `*.guard.sh` as the set union of what commands
you might have on your machine. But only those with the underlying command
installed are actually loaded. You can always `source ${file}.guard.sh`. The guard is then bypassed.
For example you could source `git.guard.sh` and it would define bash functions like `git.unzip`.
You could even invoke `git.unzip`. But it will fail without the underlying `git` command itself.

Many `${command}.{guard,source}.sh` files will define an exported function `${command}.session`, for example `git.session`. This function is called by `session.start()` and
does what `.bashrc` generally does. This might include sourcing function definitions that are _not_ exported and
binding `readline` functions. Session functions makes it easy to
to replay what `.bashrc` would do with the added benefit that
customizations are concentrated in a single file, e.g. `git.guard.sh`. 

These conventions are a work in progress and subject to change. But understanding the layout aids navigation and use. Basically you're buying into a slew of global, exported functions loaded when you start a login shell. These functions are all exported to subshells. Some of the functions follow patterns for later use such as `${command}.session`. But
the conventions are simple and promote a copy-and-adapt style. `profile.d/_template.sh` provides a good starting place for your scripts, e.g. if you want a guard for the command `foo` you can start with `cp _template.sh foo.guard.sh` and modify `foo.guard.sh`.

## <a id="hacking">Hacking</a>

I use emacs. You should use what suits you. But it should be emacs.

<!-- 
## More

* [pj/doc/README.md](pj/doc/README.md) is the entry into the documentation.
* [pj/doc/todo.md](pj/doc/todo.md) lists action items and questions.
-->



## <a id="usage">Usage</a>

You're through the hard part. Using bashenv is easy. When you create a login session in bash, bash sources `~/.bash_profile`. When you create a new shell, bash sources `~/.bashrc`. Since a login shell is also a new shell, you source both. (The bash rules are actually somewhat more
complicated than this. I'm waving my hands here.)

Bashenv traffics in bash functions which are all loaded from `~/bashenv/profile.d/**.sh`. Bash functions are underappreciated and underutilized. In particular, just like environment variables they can be exported and therefore visible to all subshells without redefinion or reloading. You can, of course, load a new definition for the same name in subshell. But generally there's little need.

Because you have to explicitly export a function after defining it using the exotic `declare -fx ${function}`, functions are often sourced (and sourced again and again and again) via `~/.bashrc`. With just an extra declaration this is completely unnecessary. You can have convenience _and_ start subshells quickly with bashenv. But I'm not claiming credit for this. Just learn `declare -fx`.

### <a id="usage-without-git">Usage Without Git</a>

Set aside your existing `~/.bash_profile` and `~/.bashrc` in `~/.bashenv-recover` and then link to `bashenv/.bash_profile` and `bashenv/.bashrc` respectively:

```bash
mkdir -p ~/.bashenv-recover
mv -v ~/.bash_profile ~/.bashrc ~/.bashenv-recover
ln -srf ~/bashenv/.bash_profile
ln -srf ~/bashenv/.bashrc
```

If you want to take a more incremental approach you can add bashenv loading to the bottom of `~/.bash_profile` and `~/.bashrc` respectively:

```bash
echo '[[ -r ~/bashenv/.bash_profile ]] && source ~/bashenv/.bash_profile` >> ~/.bash_profile
echo '[[ -r ~/bashenv/.bashrc ]] && source ~/bashenv/.bashrc` >> ~/.bashrc
```

You're done! You have bashenv on your next bash login session. To get it immediately: `source ~/.bash_profile && source ~/.bashrc`

### <a id="usage-with-git">Usage With Git</a>

Usage with git is configured like usage without git; you just did it above.

With git however you can add or modify bashenv scripts, commit the changes, push the changes and pull them to other machines.


## Scripting Patterns

tbs scripting patterns

Bashenv is a thought process. You install a package, say `procs` and explore it. Over time you start to incorporate it into your
workflow in a terminal. Let's suppose you installed with `asdf` rather than `dnf`, so you need to load the bash completion functions.
This leads to `profile.d/procs.guard.sh`:

```bash
procs.session() { source <(procs --gen-completion-out bash); }
f.x procs.session
```
Why? You only want to load `procs.guard.sh` if `procs` is installed. You want to load completions for convenience.
`procs` emits the bash code itself and it's function definitions are local, not global (`declare -fx`).
So you need to load the completion function(s) on each new session. But (and this can be confusing) `procs.session()` itself
is exported so that `bashenv.session.start()` can find it.

Let's suppose the default columns for `procs` are not to your liking or you want different columns in different circumstances.
Now you start giving these variants (function) names, e.g. `procs.systemd` or `procs.node`:

```bash
procs.systemd() (
   set -Eeuo pipefail
   local _process=${FUNCNAME##.*}
   procs --tree --watch ${_process} "$@"  ## completely made up
)
f.x procs.systemd

procs.node() (
   set -Eeuo pipefail
   local _process=${FUNCNAME##.*}
   procs --tree --watch ${_process} --watch-interval=10 "$@" 

)
f.x procs.node
```

So the dot in the function names like `f.x` are something like `${category}.${action}`, e.g. `procs.node`. And this convention has a nice
default behavior that completion for `procs` includes the command itself and all the bashenv additions. Don't fight the tools.

Couldn't you do this (say) with bash scripts in `~/.local/bin`? Yup. Do so if that's your preference. But personally I like
`type procs.node` to remind myself of pertinent details about `procs`. But you do you.

## Pragma(tics)

### git

I generally do much of my dev work on a (somewhat beefy) daily driver machine. I have several "satellite" hosts that
run various linux variants, virtual machines and containers. The satellites are more sacrificial than `beefy`, but not fully stateless
(think pets, not cattle, but I treat them coldly.) 
I will `git clone beefy:bashenv` from each of the satellites to simplify configuration all around.
If I fix a bug discovered on the satellite, 
I want to commit the changes back to `beefy` (and then on to github). To do this,
`beefy:bashenv/.git/config` needs this stanza to accept commits from the satellites:

```
[receive]
        denyCurrentBranch=updateInstead
```

The error message associated with the configuration default is cryptic and discusses "unsafe" repositories. I haven't managed to bolix any
of the repos yet, but ymmv, caviat emptor.

### ~/.config/**

A lot of useful configuration is kept in `~/.config/**` by command, for example `~/.config/git` for git
or `~/.config/aws` for aws and so forth.
Since these directories can contain credentials or complicated state (in the case of say `~/.config/google-chrome`), I haven't incorporated
them into `bashenv`, but no solution is really adequate without it. My current "solution" is a git repo in `~/.config` which the satellites pull from. This repo isn't public and the approach is brittle at best. The contents of `~/.config/**` often aren't meant to be shared but to be synthesized on each host (I think). Some applications seem to view this data as opaque user specific content which you touch at your peril
(I'm looking at you Chrome).

## <a id="history">History</a>

I've done a few variants of bashenv for my own use, mostly by trying to graft "modules" into bash with function naming conventions.
That's why you see function names like `f.x` (function export) or `emacs.server` (start emacs as a daemon).
Bash doesn't have modules. It doesn't even have (function) closures. There's only so much you can do here.
But I continue to ignore the memo. This will work, surely. Just. One. More. Function.

Despite the caviats, I find this stanza helpful when faced with a new install or new container:

```bash
$p sudo dnf install -y git{,-extras} direnv make ## install the prerequisites
$p git clone https://github.com/mcarifio/bashenv ## get the bits
source ~/bashenv/bin/bashenv.sh ## install it
bashenv.doctor ## check the install
```

When things break, I fix them. Each satellite benefits from the improvements. But I also let my daily needs drive the improvements
and fixes, [yagni](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it).

## <a id="raq">RAQ</a> (Randomly Asked Questions)

* Question: There are better shells to invest in, e.g. `zsh`, `fish`, `elvish`, `xonsh`, `nushell` and so forth. Why bother with this? 
  Answer: Bash is usually the default shell and you'll land in it often. A few simple patterns go a long, long way. 
  But yes, bash is imperfect as a shell _and_ as a programming language. It's also ubiquitious and unavoidable. Walk away.
  I won't see you go.
  
* Question: If I'm going to start automating things, bash is the wrong language. 
  Answer: Busted. Except that I've noticed that I can whip up a quick bash function to automate something in about 5 minutes. 
  Especially if a I start with a bash function that is similar or close. 
  And I can give that function a name that makes sense to me, that I can remember and
  that the bash shell will help complete when my memory is hazy. Which is about 10 minutes after researching some new command.
  
* Question: This is unneccessary. Use bash history. Answer: Yes, but this isn't either/or. The functions I've tended to write fall into a few patterns:
  + I change the default arguments to a command
  + I hide `sudo`.
  + I contextualize arguments to a command
  + I bash complete a command differently from the original authors.
  + I immortalize one liners.
  + I bulletproof chatgpt answers.
  + I avoid confusing bash constructs like regular expression matching using `=~`. I can stop googling `awk match`.
  
* Question: Configuation depends on system files, for example `/etc/hosts`. Answer: Busted. In my particular case, I have a local
  dns server via my router but hostname completions use `/etc/hosts` by default and "widening the scope" for this takes work and time
  I don't currently have. It also introduces networking and network management into the mix. Which isn't bad. But beyond bash functions.
  
* Question: As soon as I start modifying and adding files in `~/bashenv/profile.d`, I will diverge from this repository and pulling from the
  fork will just screw up my own repository, yes? Answer: Unfortunately yes, I think that's right. The function `bashenv.profile` in `~/.bash_profile`
  will look for `.sh` files in directory `profile-${USER}.d` as well as `profile.d`. This helps when you have several usernames as clients, e.g.
  `mcarifio` or `tester`. But it's unrealistic to dodge changes in `profile.d` especially if you make local modifications to forked files. In the worst
  case pulling from the fork might silently swallow your modifications. Low ceremony can have a high price.





