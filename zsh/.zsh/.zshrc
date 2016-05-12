# only required until my PR is merged https://github.com/tarjoilija/zgen/pull/67
export ZGEN_DIR="${ZDOTDIR:-$HOME}/.zgen"
# automatically regenerate init files on changes
export ZGEN_RESET_ON_CHANGE=(${ZDOTDIR:-$HOME}/.zshrc)
# set prezto repo to own fork
export ZGEN_PREZTO_REPO="alexconst"
# initialize/load zgen
source "${ZDOTDIR:-$HOME}/.zgen/zgen.zsh"

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    # prezto options
    zgen prezto editor key-bindings 'vi'
    zgen prezto prompt theme 'agnoster'
    zgen prezto utility:ls color 'yes'
    #zgen prezto utility:diff color 'yes'
    zgen prezto '*:*' color 'yes'

    # prezto and modules
    zgen prezto
    zgen prezto command-not-found
    zgen prezto syntax-highlighting
    #zgen prezto utility
    zgen prezto editor
    zgen prezto prompt

    zgen save
fi

# load additional generic config
for dotfile in "${ZDOTDIR:-$HOME}"/.zshrc.d/*zsh; do
    source "${dotfile}"
done

# load machine specific config
file="${ZDOTDIR:-$HOME}/.zshrc.user"
if [[ -f "${file}" ]]; then
    source "${file}"
fi

