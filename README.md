# About

Deploys dotfiles into new system.
Supports both public (eg: github) and private (eg: your private server) repos. It "merges" (ie, links) the files in the private repo to `$HOME` (which typically means directories in the public repo).
*Smooth!*

The adopted convention for private files is the same used by [YADR](https://github.com/skwp/dotfiles), where they use the suffix `*.user` (and eventual secrets will be stored in `.secrets`).


# Install

```bash
setopt interactivecomments

# set "home" directory
export MYHOME="$HOME/home"
mkdir -p "$MYHOME" && cd "$MYHOME"
# work around catch22 to get github SSH keypair
cp -p -r /vagrant/dotfiles_private "$MYHOME/"
# deploy github SSH keypair
cp -p $MYHOME/dotfiles_private/ssh/.ssh/* $HOME/.ssh/
chmod 600 $HOME/.ssh/github_rsa

# clone this repo
git clone git@github:alexconst/dotfiles.git
cd dotfiles
# bootstrap submodules
git submodule init
git submodule update
git submodule foreach 'git checkout master'
# simulate
./dotfiles.sh -s .
# deploy dotfiles
./dotfiles.sh -e .

# deploy private dotfiles (directory must have substring `private` in its name)
cd ../dotfiles_private
../dotfiles/dotfiles.sh -s .
../dotfiles/dotfiles.sh -e .

# logout and login
exit
vagrant ssh
```


# Update

```bash
cd $MYHOME/dotfiles

# update using remote 'origin'
remote="origin"
# update using remote 'upstream'
remote="upstream"

# simulate
./dotfiles.sh -g . "$remote"
# update
./dotfiles.sh -u . "$remote"
```


# TODO

- rewrite `dotfiles.sh` (using getops) because it grew up to be a little monster

