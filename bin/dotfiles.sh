#!/usr/bin/env zsh


###############################################################################
# HELP FUNCTION
###############################################################################
usage() {
    hello="hello"
    printf "\n"
    printf "dotfile installation:\n"
    printf "    $(basename $0) <command> <dir>\n"
    printf "    <command>\n"
    printf "        %-30s %s\n" "-s | --simulate" "do not perform any changes, just dry run"
    printf "        %-30s %s\n" "-e | --execute" "symlink files and folders"
    printf "        %-30s %s\n" "-d | --delete" "delete links"
    printf "        %-30s %s\n" "-r | --reexecute" "delete links and then link them again"
    printf "    %-34s %s\n" "<dir>" "source dotfiles dir (eg: \$HOME/dotfiles)"
    printf "dotfile plugin update:\n"
    printf "    $(basename $0) <command> <dir> <remote>\n"
    printf "    <command>\n"
    printf "        %-30s %s\n" "-a | --add" "add predefined upstream repos"
    printf "        %-30s %s\n" "-u | --update" "update installed plugins from 'upstream' and also push to 'origin'"
    printf "        %-30s %s\n" "-g | --gimulate" "do not perform any changes, just print what would be done with git"
    printf "    %-34s %s\n" "<dir>" "source dotfiles dir (eg: \$HOME/dotfiles)"
    printf "    %-34s %s\n" "<remote>" "with <remote> being 'origin' or 'upstream'"
    printf "\n"
    exit 1
}




###############################################################################
# ARGUMENT PARSING
###############################################################################
# TODO: replace with getopt

if [[ $# -lt 1 ]]; then
    usage
fi
mode="$1"
dotfiles="$(readlink -f $2 )"
if [[ -z "$dotfiles" ]]; then
    printf "ERROR: no such directory: $2\n"
    exit 2
fi
remote="$3"

# ignore option ignores files ending in Perl regex (so no need for .*)
stow_opts="--ignore='swp' --verbose=2"
mode_execute=0
mode_delete=0
mode_modify=0
mode_update=0
mode_gimulate=0
mode_add=0
case $mode in
    -s|--simulate)
        stow_opts+=" -n"
        ;;
    -e|--execute)
        mode_modify=1
        mode_execute=1
        ;;
    -r|--reexecute)
        stow_opts+=" -R"
        mode_modify=1
        mode_execute=1
        mode_delete=1
        ;;
    -d|--delete)
        stow_opts+=" -D"
        mode_modify=1
        mode_delete=1
        ;;
    -a|--add)
        mode_add=1
        mode_modify=1
        ;;
    -u|--update)
        mode_update=1
        mode_modify=1
        ;;
    -g|--gimulate)
        mode_gimulate=1
        ;;
    *)
        usage
        ;;
esac

if [[ "$dotfiles" =~ "private" ]]; then
    private=1
    public=0
else
    private=0
    public=1
fi

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
    src_dir="$1"
    dst_dir="${2:-$HOME}"
    items=($(cd "$src_dir" ; find . -print | tail -n+2))
    for item in "${items[@]}"; do
        src=$(readlink -f "$src_dir/$item")
        dst_lnk="$dst_dir/${item#./}"
        dst=$(readlink -f $dst_lnk)
        #echo "$item"
        #echo "src = $src"
        #echo "dst = $dst"
        # if $src and $dst point to same file, then nothing to do here
        if [[ "$src" == "$dst" ]] && [[ "$mode_delete" -eq 0 ]]; then
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
                if [[ "$mode_execute" -eq 1 ]]; then
                    eval "$cmd"
                fi
            fi
        fi
        # handle files
        if [[ -f "$src" ]]; then
            if [[ -f "$dst" ]]; then
                if [[ "$mode_delete" -eq 1 ]]; then
                    cmd="rm $dst_lnk"
                    printf "+ Link will be removed: $cmd\n"
                fi
                if [[ "$mode_execute" -eq 1 ]]; then
                    cmd="ln -sf $src $dst"
                    printf "+ File/link '$dst' will be replaced with a symbolic link to '$src'\n"
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

cmd_exec () {
    cmd="$@"
    curr_dir=$(pwd)
    printf "%-100s %s\n" "+ Will execute command: $cmd" "Work dir: $curr_dir" 
    if [[ "$mode_gimulate" -eq 0 ]] && [[ "$mode_simulate" -eq 0 ]]; then
        eval "$cmd"
    fi
}

git_pull_push () {
    git remote | grep "upstream" >/dev/null
    if [[ "$?" -eq 0 ]]; then
        cmd="git pull -u upstream master"
        cmd_exec "$cmd"
        cmd="git push -u origin master"
        cmd_exec "$cmd"
    else
        printf "WARNING: no remote upstream defined\n"
        cmd="git pull -u origin master"
        cmd_exec "$cmd"
    fi
}

zsh_update () {
    if [[ -f "$HOME/.zshenv" ]]; then
        source "$HOME/.zshenv"
    fi
    cd "${ZDOTDIR:-$HOME}/.zgen"
    #echo "$dotfiles"
    #echo "remote = '$remote'"
    if [[ "$remote" == "origin" ]]; then
        cmd="true"
        cmd_exec "$cmd"
    elif [[ "$remote" == "upstream" ]]; then
        cd ../.zprezto
        git_pull_push
        cd ../.zgen
        git_pull_push
    else
        printf "ERROR: '$remote' is not a valid remote. Only 'origin' and 'upstream' are suported.\n"
        exit 3
    fi
    source "${ZDOTDIR:-$HOME}/.zgen/zgen.zsh"
    cmd="zgen update"
    cmd_exec "$cmd"
    cmd="zgen selfupdate"
    cmd_exec "$cmd"
}

zsh_add () {
    cd "${ZDOTDIR:-$HOME}/.zgen"
    cmd="git remote add upstream git@github:tarjoilija/zgen.git"
    cmd_exec "$cmd"
    cd "${ZDOTDIR:-$HOME}/.zprezto"
    cmd="git remote set-url origin git@github:alexconst/prezto.git"
    cmd_exec "$cmd"
    cmd="git remote add upstream git@github:sorin-ionescu/prezto.git"
    cmd_exec "$cmd"
}

bin_install () {
    if [[ -d "${dotfiles}/bin" ]]; then
        eval "stow ${stow_opts} -d ${dotfiles} -t ${MYHOME:-$HOME}/bin bin"
    fi
}

misc_install () {
    target="$1"
    if [[ "$public" -eq 1 ]]; then
        stow_exec "$target"
    else
        hammer_time "$target"
    fi
}



###############################################################################
# EXECUTION
###############################################################################

# update tools
if [[ "$mode_update" -eq 1 ]] || [[ "$mode_gimulate" -eq 1 ]]; then
    zsh_update
# add upstream repos metadata
elif [[ "$mode_add" -eq 1 ]]; then
    zsh_add
# deploy the dotfiles
else
    mkdir -p "${MYHOME:-$HOME}/bin"

    zsh_install
    bin_install
    misc_install "misc"
fi


