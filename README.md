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

## Usage

### Configuration

All configuration is stored in `INSTALEE_HOME` 
which defaults to `$XDG_CONFIG_HOME/instalee`.

First, customize the _handlers_ available on your system in `$INSTALEE_HOME/handlers.available`
which is a newline-separated list of values 
that usually correspond to subdirectories of the `handlers` directory.
The order determines the preference in which the _handlers_ are consulted.

The following should be kept in mind when configuring instalee
- `handlers.available` is a system-specific file,
  for sensible syncing across many different machines
  a mechanism such as [yasm alternate files](https://yadm.io/docs/alternates)
  can prove useful.
- `collections` are usually personal, but system-agnostic
- `handlers` and `packages` need to be attuned,
  as the package entry format needs to fit the handler definitions.
  These may be obtained from a trusted source
  or configured personally as well.

This repository contains an example configuration
as used by the author.
See the [man page](instalee.1) for more details.

### Installation

`instalee <target>`

A _target_ may either be a _package_ or a _collection_.
*Instalee* first checks for a `collections/<target>` file.
A _collection_ is a newline-separated list of packages to install,
which *instalee* then resolves individually.

When there is no corresponding _collection_,
*instalee* searches for the first available _handler_
with a corresponding entry at `packages/<target>/<handler>`,
piping it into the _handler_ to install the package.
The package definition may be an empty file
(thus simply indicating the availability of a package for a _handler_),
in which case the name of the package is passed to the _handler_.

Note that both _collections_ and package entries can be executable files,
in which case *instalee* will execute them and use their output instead,
so watch the file permissions!
If an available _handler_ has no definition in `handlers`,
the package file _has to be_ executable,
as *instalee* will then simply execute it.
This _handler_ is usually named `custom`,
though that is no requirement.

### Handlers

Though not required,
a typical handler will accept 
a newline-separated list of packages to install,
enabling batching and the consolidation of interdependent packages into one unit.


## What instalee is not
- a (central) package repository containing package sources
- a package manager that can inspect or remove packages

## Planned
- detection mechanism for handlers and features
  (e.g. whether they support batching)
- helper/hook for adding packages to collections upon install
  (at least for `pacman`)
