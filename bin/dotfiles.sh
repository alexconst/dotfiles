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
dotfiles="$(readlink -f $2 )"

if [[ "$dotfiles" =~ "private" ]]; then
    private=1
    public=0
else
    private=0
    public=1
fi

# ignore option ignores files ending in Perl regex (so no need for .*)
stow_opts="--ignore='swp' --verbose=2"
mode_modify=0
mode_delete=0
mode_upstream=0
case $mode in
    -s|--simulate)
        stow_opts+=" -n"
        ;;
    -e|--execute)
        mode_modify=1
        ;;
    -r|--reexecute)
        stow_opts+=" -R"
        mode_modify=1
        ;;
    -d|--delete)
        stow_opts+=" -D"
        mode_delete=1
        mode_modify=1
        ;;
    -u|--update)
        mode_upstream=1
        ;;
    *)
        usage
        ;;
esac

if [[ "$mode_modify" -eq 0 ]]; then
    printf "SIMULATION MODE: no changes will be made\n\n"
else
    printf "EXECUTION MODE: file system changes will be done\n\n"
fi




###############################################################################
# INSTALLATION FUNCTIONS
###############################################################################
# sadly each target has its own quirks so is it not possible to refactor much

stow_exec () {
    stow_cmd="stow ${stow_opts} -d ${dotfiles} -t ${HOME}"
    eval "${stow_cmd} $1"
    printf "\n"
}


# Recursively creates a symbolic link for each file
# Since stow doesn't support "merging" we need to hammer it
# It is really corner case pilling, eg: handling private history file or config
hammer_time () {
    items=($(cd "$1" ; find . -print | tail -n+2))
    for item in "${items[@]}"; do
        src=$(readlink -f "$1/$item")
        dst="$HOME/${item#./}"
        dst=$(readlink -f $dst)
        #echo "$item"
        #echo "src = $src"
        #echo "dst = $dst"
        # if $src and $dst point to same file, then nothing to do here
        if [[ "$src" == "$dst" ]]; then
            printf -- "- Nothing to do since source and dest are the same: $src\n"
            continue
        fi
        # handle directories
        if [[ -d "$src" ]]; then
            if [[ -d "$dst" ]]; then
                printf -- "- Nothing to do since destination directory already exists: $dst\n"
            else
                cmd="mkdir -p $dst"
                printf "+ Will execute command: $cmd\n"
                if [[ "$mode_modify" -eq 1 ]]; then
                    eval "$cmd"
                fi
            fi
        fi
        # handle files
        if [[ -f "$src" ]]; then
            cmd="zzzzzzzz"
            if [[ -f "$dst" ]]; then
                if [[ "$mode_delete" -eq 1 ]]; then
                    cmd="rm $dst"
                    printf "+ Link will be removed: $cmd\n"
                else
                    cmd="ln -sf $src $dst"
                    printf "+ File '$dst' will be overwriten with link to '$src'\n"
                fi
            else
                cmd="ln -sf $src $dst"
                printf "+ Link will be created: $cmd\n"
            fi
            if [[ "$mode_modify" -eq 1 ]]; then
                eval "$cmd"
            fi
        fi
    done
}


zsh_install () {
    if [[ "$public" -eq 1 ]]; then
        stow_exec "zsh"
        if [[ "$mode_modify" -eq 1 ]]; then
            if [[ -f "$HOME/.zshenv" ]]; then
                source "$HOME/.zshenv"
            fi
        fi
    else
        hammer_time "zsh"
    fi
}

bin_install () {
    if [[ -d "${dotfiles}/bin" ]]; then
        eval "stow ${stow_opts} -d ${dotfiles} -t ${MYHOME:-$HOME}/bin bin"
    fi
}




###############################################################################
# EXECUTION
###############################################################################
if [[ "$mode_upstream" -eq 1 ]]; then
    # TODO git pulls
    exit 0
fi

mkdir -p "${MYHOME:-$HOME}/bin"


zsh_install
bin_install

