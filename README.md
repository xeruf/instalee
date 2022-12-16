# Instalee

Inspired by [pass](passwordstore.org "The standard Unix password manager")
and the Unix philosophy 
comes a small POSIX-compliant shell script
to aid in setting up and keeping installed packages on machines in sync.
Central feature is the modular directory structure 
that can handle everything from native package managers 
over installation from source
to copying or executing scripts from a URL.
Similar to [tldr](https://github.com/tldr-pages/tldr),
creating alternative frontends is easy and appreciated.

Instalee can install the same set of packages on any system
with graceful failure if any package is unavailable.
With appropriate setup and logging (TBD)
it can also keep the installed packages in sync.
Simply, Instalee can be used as a unified installation frontend,
both manual and automatic,
to any package manager or other method of installation
on any system with a POSIX Shell available
(and the basic logic is so simple 
you could easily port it to another foundation,
preserving the file structure).

## Usage

### Installation

To try Instalee with some pre-configured options,
clone or download the repository and run the included script.
Currently this supports Debian- and Arch-based systems,
as well as a few packages via *snap*, *cargo* and custom scripts
usually imported from the original project site.

Alternatively, you can download just the [`instalee`](./instalee) script
and configure it yourself.
On Arch you can install the script to `/usr/bin` 
and the man-page with the `instalee-git` AUR package.

An install helper for Windows,
that prepares chocolatey either on- and offline
and installs git bash, is in the works.

### Configuration

All configuration is stored in `INSTALEE_HOME` 
which defaults to the first available of
`$XDG_CONFIG_HOME/instalee` or the current directory.

First, customize the _handlers_ available on your system 
in `$INSTALEE_HOME/handlers.available`
which is a newline-separated list of values 
that usually correspond to subdirectories of the `handlers` directory.
The _handlers_ are tried in the order they are listed.

Keep the following in mind when configuring Instalee:
- `handlers.available` is a system-specific file,
  for sensible syncing across many different machines
  a mechanism such as [yasm alternate files](https://yadm.io/docs/alternates)
  can prove useful.
- `groups` are usually personal, but system-agnostic
- `handlers` and `packages` need to be attuned,
  as the package entry format needs to fit the handler definitions.
  These may be obtained from a trusted source
  or configured personally.

This repository contains an example configuration as used by the author.
See the [man page](instalee.1) for more details.

### Installing Packages

`instalee <target>`

A _target_ may either be a _package_ or a _group_.
Instalee first checks for a `groups/<target>` file.
A _group_ is a newline-separated list of packages to install,
which instalee then resolves individually.
One difference here is that it will try the first handler for the package
if it has no associated definition.

When there is no corresponding _group_,
instalee searches for the first available _handler_
with a corresponding entry at `packages/<target>/<handler>`,
piping it into the _handler_ to install the package.
The package definition may be an empty file
(thus simply indicating the availability of a package for a _handler_),
in which case the name of the package is passed to the _handler_.

Note that both _groups_ and package entries can be executable files,
in which case instalee will execute them and use their output instead,
so watch the file permissions!
If an available _handler_ has no definition in `handlers`,
the package file _has to be_ executable,
as instalee will then simply execute it.

### Handlers

Though not required,
a typical handler will accept a list of packages to install as arguments,
enabling batching and the consolidation of interdependent packages into one unit.

When installing a package and there is no handler available,
but a package with the name of a handler of the package has an installable candidate,
the handler will be installed, made available and used.

When installing packages from groups without candidate,
the first available handler will be tried regardless
so default-named packages do not always need to setup explicitly
(TODO: Auto-update repo if that succeeds with flag to disable,
flag for manual installation).

## Guiding Principles

Instalee closely follows the UNIX philosophy with directory structures and files as configuration.
The goal is to be as generic as possible to accomodate any kind of setup.

However, it should be efficient while generic,
preventing repetition at every level (DRY).

### What Instalee is not
- a (central) package repository containing package sources
- a package manager to inspect or remove packages
- a tool to upgrade all installed packages from various sources -
  see `topgrade`

## Features

A loose list of undocumented features 
and ideas that need to be fleshed out.

- Cross-handler dependencies (e.g. logcli script needs go)
  -> currently implemented with `HANDLER_depends` files

### Planned
- detection mechanism for handlers and features
  (e.g. whether they support batching)
- Ability to use multiple repos, including remote ones
- Handle missing versions in older os version repos

- helper/hook for adding packages to groups upon install
  (at least for `pacman`)
- Log Installs for reuse

### Random TODOs
- Debug corner cases
- Handler preparation - update repos and cache last update time in /tmp
- Run file in tempdir by default?
- Handler for downloaded scripts (e.g. passff-host, funkwhale)
- Enable services after install, e.g. syncthing and docker

#### Windows Flow
- Install choco and git offline
- Run in git bash
- TODO: Use choco-offline sources

### Flow
This is a revamped concept 
that would ease setting up new devices with different systems
by adding a mapping of functions to applications
as well as handlers to providers
(e.g. different make mechanisms on Arch and Debian).
That way, the same functionality is available everywhere,
but can be provided by different packages
as different systems have different users.
The following tables lists some real-world examples to consider,
but the details still need to be fleshed out.

| Function       | Package/Application | Handler              | Provider      | System        |
|----------------|---------------------|----------------------|---------------|---------------|
| pdf            | okular              | chocolatey           | chocolatey    | Windows       |
|                | zathura             | arch                 | pacman or yay | Arch          |
|                | timg poppler        | apt                  | apt           | Debian Server |
| loki           | loki                | arch                 | pacman or yay | Arch          |
|                |                     | make                 | checkinstall  | Debian        |
|                |                     | make                 | wocka         | Arch          |
| logcli         | loki-logcli         | script (depends: go) | script        | Debian        |
|                |                     | arch                 | pacman or yay | Arch          |
|                | logcli-bin          | aur                  | yay           | Arch          |
| zoom           | zoom                | deb                  | apt           | Debian        |
|                |                     | aur                  | yay           | Arch          |
| screen-capture | spectacle peek      | arch                 | pac/yay       | Arch          |
|                | screentogif         | chocolatey           | chocolatey    | Windows       |
| aur            | yay                 | aur                  | makepkg       | Arch          |
|                |                     | aur                  | yay           |               |

- Software and Provider are derived from Function and Handler but can change depending on the system
  -> no way of declaring function so far, maybe via groups somehow?
- Idea: `providers/<provider>/<handler>[_<ext>]` rather than `handlers/<handler>/install[_<ext>]`
  + but then one might duplicate the handler script if one provider handles multiple equally,
    such as `yay` for arch and aur
  + how about `providers/<handler>/<provider>[_<ext>]`? 
    Same duplication issue, now spread out...
  + underscore extension might be superfluous through that, since `ext` was somewhat a proxy for a proper `provider` configuraion
- Use system subdirectories for handlers and groups,
  which are used by default when system is detected

## Notes on this Repository

### Groups

- shell/basics: without these a linux machine is hardly usable
- shell/tools: without these, a linux computer is not productively usable for me
- shell/enhancements: replacements for commonly used, dated tools, such as `ls`->`exa` and `top`->`glances`

### Handlers



## Notable Projects

- another universal package manager,
  but without affecting the system:
  https://github.com/teaxyz/cli
- universal package updater:
  https://github.com/topgrade-rs/topgrade
