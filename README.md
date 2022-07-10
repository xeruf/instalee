# instalee

Inspired by [pass](passwordstore.org "The standard Unix password manager")
and the Unix philosophy 
comes a small POSIX-compliant shell script
to aid in setting up and keeping installed packages on machines in sync.
Central feature is the modular directory structure 
that can handle everything from native package managers 
over installation from source
to copying or executing scripts from a URL.
Similar as in [tldr](https://github.com/tldr-pages/tldr),
creating alternative frontends is easy and appreciated.

## Guiding Principles

instalee closely follows the UNIX philosophy with directory structures and files as configuration.
The goal is to be as generic as possible to accomodate any kind of setup.

However, it should be efficient while generic,
preventing repetition at every level.

## Usage

### Configuration

All configuration is stored in `INSTALEE_HOME` 
which defaults to `$XDG_CONFIG_HOME/instalee`
or the current directory.

First, customize the _handlers_ available on your system 
in `$INSTALEE_HOME/handlers.available`
which is a newline-separated list of values 
that usually correspond to subdirectories of the `handlers` directory.
The _handlers_ are tried in the order they are listed.

Keep the following in mind when configuring instalee:
- `handlers.available` is a system-specific file,
  for sensible syncing across many different machines
  a mechanism such as [yasm alternate files](https://yadm.io/docs/alternates)
  can prove useful.
- `groups` are usually personal, but system-agnostic
- `handlers` and `packages` need to be attuned,
  as the package entry format needs to fit the handler definitions.
  These may be obtained from a trusted source
  or configured personally as well.

This repository contains an example configuration
as used by the author.
See the [man page](instalee.1) for more details.

### Installation

`instalee <target>`

A _target_ may either be a _package_ or a _group_.
*Instalee* first checks for a `groups/<target>` file.
A _group_ is a newline-separated list of packages to install,
which *instalee* then resolves individually.
One difference here is that it will try the first handler for the package
if it has no associated definition.

When there is no corresponding _group_,
*instalee* searches for the first available _handler_
with a corresponding entry at `packages/<target>/<handler>`,
piping it into the _handler_ to install the package.
The package definition may be an empty file
(thus simply indicating the availability of a package for a _handler_),
in which case the name of the package is passed to the _handler_.

Note that both _groups_ and package entries can be executable files,
in which case *instalee* will execute them and use their output instead,
so watch the file permissions!
If an available _handler_ has no definition in `handlers`,
the package file _has to be_ executable,
as *instalee* will then simply execute it.

### Handlers

Though not required,
a typical handler will accept 
a newline-separated list of packages to install,
enabling batching and the consolidation of interdependent packages into one unit.

When installing a package and there is no handler available,
but a package with the name of a handler of the package has an installable candidate,
the handler will be installed, made available and used.

## Features 
- Cross-handler dependencies (e.g. logcli script needs go)
  -> currently implemented with `HANDLER_dependencies` files

### What instalee is not
- a (central) package repository containing package sources
- a package manager that can inspect or remove packages

### Planned
- detection mechanism for handlers and features
  (e.g. whether they support batching)
- helper/hook for adding packages to groups upon install
  (at least for `pacman`)

### TODOs
- Debug corner cases
- Handler preparation - update repos and cache last update time in /tmp
- Handler providers e.g. different make mechanisms on arch and debian
- Run file in tempdir by default?
- Handler for downloaded scripts (e.g. passff-host, funkwhale)

### Windows
- Install choco and git offline
- Run in git bash
- Use choco/choco-offline sources

### Flow
| Function       | Software       | Handler              | Provider      | System        |
|----------------|----------------|----------------------|---------------|---------------|
| pdf            | okular         | chocolatey           | chocolatey    | Windows       |
|                | zathura        | arch                 | pacman or yay | Arch          |
|                | timg poppler   | apt                  | apt           | Debian Server |
| loki           | loki           | arch                 | pacman or yay | Arch          |
|                |                | make                 | checkinstall  | Debian        |
|                |                | make                 | wocka         | Arch          |
| logcli         | loki-logcli    | script (depends: go) | script        | Debian        |
|                |                | arch                 | pacman or yay | Arch          |
|                | logcli-bin     | aur                  | yay           | Arch          |
| zoom           | zoom           | deb                  | apt           | Debian        |
|                |                | aur                  | yay           | Arch          |
| screen-capture | spectacle peek | arch                 | pac/yay       | Arch          |
|                | screentogif    | chocolatey           | chocolatey    | Windows       |

- Software and Provider are derived from Function and Handler but can change depending on the system
  -> no way of declaring function so far, maybe via groups somehow?
- Idea: `providers/<provider>/<handler>[_<ext>]` rather than `handlers/<handler>/install[_<ext>]`
  + but then one might duplicate the handler script if one provider handles multiple equally,
    such as `yay` for arch and aur
  + how about `providers/<handler>/<provider>[_<ext>]`? 
    Same duplication issue, now spread out...
  + underscore extension might be superfluous through that, since `ext` was somewhat a proxy for a proper `provider` configuraion
