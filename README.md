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
On Arch you can install the `instalee-git` AUR package
to get the man-page and copy the script into `/usr/bin`.

#### Windows

You can easily install instalee and its dependencies on Windows
by running the following in an administrative powershell:
``` powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
Start-Process -Wait "C:\Program Files\Git\git-bash.exe" -Verb runAs -ArgumentList "-c 'git clone https://github.com/xeruf/instalee; cd instalee && git pull && ./instalee win/office; sleep 10 || bash'"
```
This combines [the installation of chocolatey](https://chocolatey.org/install#install-step2)
with the helper script [i.ps1](./i.ps1).

It then installs the win/office group
made up of packages useful to almost anyone.
To install further packages,
open git bash in the created instalee directory
and run `./instalee PACKAGE`.

An offline version is possible as well 
but I did not get around to publishing it yet, just ask :)

### (Debian) Linux Server

The classic way I get this onto a Linux server:

```sh
cd /opt 
sudo chown --from=:root :sudo . && sudo chmod g+w .
sudo apt install git
git clone https://github.com/xeruf/instalee || git -C instalee pull
instalee/instalee shell/basics
```

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
The goal is to be as generic as possible to accommodate any kind of setup.

However, it should be efficient while generic,
preventing repetition at every level (DRY).

### What Instalee is not
- a (central) package repository containing package sources
- a package manager to inspect or remove packages
- a tool to upgrade packages installed from diverse sources -
  see `topgrade`

## Features

A loose list of undocumented features 
and ideas that need to be fleshed out.

- Cross-handler dependencies (e.g. logcli script needs go)
  -> currently implemented with `depends_HANDLER` files

### Planned
- detection mechanism for handlers and features
  (e.g. batch-install support)
- Ability to use multiple repos, including remote ones
- Cope with missing versions in repositories of older OS versions
  -> version handlers

- helper/hook for adding packages to groups upon install
  (at least for `pacman`)
- Log Installs for reuse

### TODOs
- Homebrew for Mac - partially implemented but resolution not working (e.g. docker automatically installing brew first)
- Somehow installing doom emacs has a dependency tree resolution issue
- Debug corner cases: Not working on Windows when run as Admin
- Handler preparation - update repos and cache last update time in /tmp
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
  + underscore extension might be superfluous through that, since `ext` was somewhat a proxy for a proper `provider` configuration
- Use system subdirectories for handlers and groups,
  which are used by default when system is detected

## Notes on this Repository

### Groups

#### [./groups/shell](shell)

- shell/basics: without these a linux machine is hardly usable
- shell/tools: without these a linux computer is not productively usable for me
- shell/enhancements: replacements for commonly used, dated tools, such as `ls`->`exa` and `top`->`glances`

#### [./groups/arch](arch)

- tools: utilities required for my dotfiles and daily use
- base: opinionated (slightly bloated) base system
- full: normal install
- all: every package I use somewhat regularly
- portable: base but with packages for installations on removable media


### Handlers

...

## Notable Projects

- another universal package manager,
  but without affecting the system:
  https://github.com/teaxyz/cli
- universal package updater:
  https://github.com/topgrade-rs/topgrade


## Windows Issues

https://superuser.com/questions/55809/how-to-run-program-from-command-line-with-elevated-rights

- auto-elevation of choco
- post-choco-install check if launching git bash works
- add choco to handlers

Set-Location : Illegales Zeichen im Pfad.
In K:\instalee\packages\chocolatey\powershell.ps1:24 Zeichen:5
+     Set-Location $Loc.Substring(1,$Loc.Length-1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (K:\instalee":String) [Set-Location], ArgumentException
    + FullyQualifiedErrorId : ItemExistsArgumentError,Microsoft.PowerShell.Commands.SetLocationCommand

Set-Location : Der Pfad "K:\instalee"" kann nicht gefunden werden, da er nicht vorhanden ist.
In K:\instalee\packages\chocolatey\powershell.ps1:24 Zeichen:5
+     Set-Location $Loc.Substring(1,$Loc.Length-1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (K:\instalee":String) [Set-Location], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.SetLocationCommand

https://stackoverflow.com/questions/52223872/get-windows-version-from-git-bash

Windows 7: https://dotnet.microsoft.com/en-us/download/dotnet-framework
-> Unsupported Versions: 4.5
