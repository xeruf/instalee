# Repository Guidelines

## Project Structure & Module Organization
`instalee` is the POSIX `sh` entrypoint. `handlers/` contains installer backends such as `apt`, `arch`, `brew`, and `binary`, each centered on an `install` script. `packages/<name>/` stores per-handler package definitions, for example `packages/git/apt` or `packages/git/chocolatey`. `groups/` contains newline-separated bundle definitions such as `groups/shell/basics` and `groups/win/office`. Supporting docs and helper scripts live in `README.md`, `instalee.1`, `i.ps1`, and `util/`.

## Build, Test, and Development Commands
There is no compiled build step. Typical contributor commands are:

- `./instalee --help`: open the man page or usage help.
- `./instalee --handlers`: list handlers visible from the active `handlers.available`.
- `INSTALEE_HOME=$PWD ./instalee -x group/shell/basics`: dry-run a group without executing package installers.
- `INSTALEE_HOME=$PWD ./instalee git`: resolve and install a single package using this checkout as config.
- `sh -n instalee handlers/*/install util/setup-repo.sh`: syntax-check core scripts before sending changes.

## Coding Style & Naming Conventions
Write portable POSIX shell, not Bash-specific code,
unless a file already targets another shell or platform such as PowerShell.
Follow the existing style:
tabs for shell indentation,
short functions,
lowercase variable names,
and terse comments only where behavior is non-obvious.
Use semantic line breaks in Markdown documentation.
Name handler scripts by action (`install`, `install_deb`, `install_pipx`)
and package entries by handler name (`packages/<pkg>/apt`, `packages/<pkg>/aur`).
Keep group files newline-separated and comment lines with `#`.

## Testing Guidelines
This repository does not currently include an automated test suite. Validate changes with targeted dry runs and syntax checks. For package or group edits, run the smallest relevant command, for example `INSTALEE_HOME=$PWD ./instalee -x group/dev/node` or `INSTALEE_HOME=$PWD ./instalee -x fd`. If you change handler behavior, exercise at least one real package path that uses that handler and note the platform used.

## Commit & Pull Request Guidelines
Use scoped commit subjects. For behavior changes, prefer semantic scopes such as `feat: ...`, `fix: ...`, or `docs: ...`. For data-only changes, scope by the modified area, for example `handlers: ...`, `groups: ...`, `packages: ...`, or `instalee: ...`. Keep each commit focused on one area and use the imperative mood. 
