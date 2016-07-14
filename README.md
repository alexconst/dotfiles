# About

Deploys dotfiles into new system.
Supports both public (eg: github) and private (eg: your private server) repos. It "merges" (ie, links) the files in the private repo to `$HOME` (which typically means directories in the public repo).
*smooth*

The adopted convention for private files is the same used by [YADR](https://github.com/skwp/dotfiles), where they use the suffix `*.user` (and eventual secrets will be stored in `.secrets`).


# Requirements

- `.ssh/config` needs to have a `github` entry configured for `github.com`. And because this is a personal environment, just copy all of the private dotfiles.
    ```bash
    # cd to the directory with the Vagrantfile
    # cp -p -r $HOME/.../dotfiles_private dotfiles_private
    ```


# Install

```bash
setopt interactivecomments

# set "home" directory
export MYHOME="$HOME/home"
mkdir -p "$MYHOME" && cd "$MYHOME"
# work around catch22 to get github SSH keypair
cp -p -r /vagrant/dotfiles_private "$MYHOME/"
# deploy github SSH keypair
for item in `find $MYHOME/dotfiles_private/ssh/.ssh/ -type f`; do ln -s `readlink -f "$item"` $HOME/.ssh/; done
chmod 600 `readlink -f $HOME/.ssh/github_rsa`

# clone this repo (remove the echo if you're concerned about MitM attacks)
echo "yes" | git clone git@github:alexconst/dotfiles.git
cd dotfiles
# tweak submodules to use your own repos (note the .ssh/config alias of github)
#sed -i 's/github:alexconst/github:your_username/g' .gitmodules
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

# now, after prezto has initialized, set HEAD to the tip of the master branch
cd ${ZDOTDIR:-$HOME}/.zgen
git checkout master
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

