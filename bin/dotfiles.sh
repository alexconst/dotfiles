#!/usr/bin/env bash


###############################################################################
# HELP FUNCTION
###############################################################################
usage() {
    hello="hello"
    printf "\nUSAGE: $(basename $0) <command> <dir>\n"
    printf "    %-30s %s\n" "<dir>" "source dotfiles dir (eg: \$HOME/dotfiles)"
    printf "Commands for dotfile installation:\n"
    printf "    %-30s %s\n" "-s | --simulate" "do not perform any changes, just dry run"
    printf "    %-30s %s\n" "-e | --execute" "symlink files and folders"
    printf "    %-30s %s\n" "-d | --delete" "delete links"
    printf "    %-30s %s\n" "-r | --reexecute" "delete links and then link them again"
    printf "Commands for dotfile plugin update:\n"
    printf "    %-30s %s\n" "-u | --update" "update installed plugins"
    printf "\n"
    exit 1
}




###############################################################################
# ARGUMENT PARSING
###############################################################################
if [[ $# -lt 1 ]]; then
    usage
fi
mode="$1"
dotfiles="$2"


# ignore option ignores files ending in Perl regex (so no need for .*)
stow_opts="--ignore='swp' --verbose=2"
mode_install=0
mode_update=0
case $mode in
    -s|--simulate)
        stow_opts+=" -n"
        ;;
    -e|--execute)
        mode_install=1
        ;;
    -r|--reexecute)
        stow_opts+=" -R"
        mode_install=1
        ;;
    -d|--delete)
        stow_opts+=" -D"
        ;;
    -u|--update)
        mode_update=1
        ;;
    *)
        usage
        ;;
esac




###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################
# sadly each target has its own quirks so is it not possible to refactor much

stow_exec () {
    stow_cmd="stow ${stow_opts} -d ${dotfiles} -t ${HOME}"
    eval "${stow_cmd} $1"
    printf "\n"
}

zsh_install () {
    stow_exec "zsh"
    if [[ "$mode_install" -eq 1 ]]; then
        if [[ -f "$HOME/.zshenv" ]]; then
            source "$HOME/.zshenv"
        fi
        rm -f "${ZDOTDIR:-$HOME}/.zprezto"
        ln -s "${ZDOTDIR:-$HOME}/.zgen/sorin-ionescu/prezto-master" "${ZDOTDIR:-$HOME}/.zprezto"
    fi
}

bin_install () {
    eval "stow ${stow_opts} -d ${dotfiles} -t ${MYHOME:-$HOME}/bin bin"
}




###############################################################################
# EXECUTION
###############################################################################
if [[ "$mode_update" -eq 1 ]]; then
    # TODO git pulls
    exit 0
fi

if [[ "$mode_install" -eq 1 ]]; then
    mkdir -p "${MYHOME:-$HOME}/bin"
fi


zsh_install
bin_install

