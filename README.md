# About

Deploys dotfiles into new system.
Supports both public (eg: github) and private (eg: your private server) repos. It "merges" (ie, links) the files in the private repo to `$HOME` (which typically means directories in the public repo).
*Smooth!*

The adopted convention for private files is the same used by [YADR](https://github.com/skwp/dotfiles), where they use the suffix `*.user` (and eventual secrets will be stored in `.secrets`).


# How to

1. fork or clone this repo
1. `export MYHOME=$HOME/...` if you want `bin` saved somewhere else
1. `cd dotfiles`
1. execute `./dotfiles.sh -e .`
1. optional (*)
1. logout and login

(*) add/merge your private dotfiles (directory must have substring `private` in its name)
1. `cd dotfiles_private`
1. execute `./dotfiles.sh -e .`

