#!/bin/bash

show_help() {
cat << EOF
${0##*/}: github wrapper to make life easier

${0##*/} CMD
    --help
        Display this help and exit

    --dry-run
        Don't do anything, just print what would be done

    --clone REPO
        Clone REPO using as remote HOST instead of 'github.com'
        ('github' is defined in .ssh/config to use specific SSH keys)
        Example: ${0##*/} --clone https://github.com/mitchellh/vagrant-aws

    --fork REPO
        Clone REPO, using as remote HOST instead of 'github.com', from USER, and add upstream remote
    It uses the github API and reads credentials from variables \$GITHUB_USER and \$GITHUB_PASS
    If github API use fails it will assume the repo was forked via web, and will still clone from your USER
        Example: ${0##*/} --fork https://github.com/mitchellh/vagrant-aws
        This would clone from git@github/alexconst/vagrant-aws and add as upstream git@github/mitchellh/vagrant-aws

    --submodule REPO
        Similar to --fork, but instead of cloning the repo to the local system, it adds it as a submodule

    --host HOST
        By default 'github' is used as HOST

    --user USER
        By default 'alexconst' is used as USER

Example:
    ${0##*/} --fork "https://github.com/mitchellh/vagrant-aws" --host github --user alexconst
    ${0##*/} --fork "mitchellh/vagrant-aws"

EOF
exit
}


host="github"
user="alexconst"
dryrun=0


if [ "$#" -eq 0 ]; then
    show_help
fi
while :; do
    case $1 in
        --help)
            show_help
            ;;
        --dry-run)
            dryrun=1
            ;;
        --clone|--fork|--submodule|--host|--user)
            if [ -n "$2" ]; then
                cmd="$1"
                option="$2"
                shift
            else
                printf 'ERROR: "%s" requires a non-empty option argument.\n' "$cmd" >&2
                exit 1
            fi
            ;;&         # ;;& allows bash to continue testing the next cases
        --clone|--fork|--submodule)
            usercmd="$cmd"
            repo="$option"
            ;;
        --host)
            host="$option"
            ;;
        --user)
            user="$option"
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: If no more options then break out of the loop.
            if [ -n "$1" ]; then
                printf 'WARN: Unknown parameter (ignored): %s\n' "$1" >&2
            fi
            break
    esac

    shift
done


# canonalize repo name
if [[ ! "$repo" =~ ^https:// ]]; then
    repo="https://github.com/$repo"
fi
origin=""
upstream=""


if [[ "$dryrun" -eq 1 ]]; then
    printf "usercmd = %s\n" "$usercmd"
    printf "repo = %s\n" "$repo"
    printf "host = %s\n" "$host"
    printf "user = %s\n" "$user"
    printf "SIMULATION MODE: no changes will be made\n\n"
fi




cmd_exec () {
    cmd="$@"
    curr_dir=$(pwd)
    if [[ "$dryrun" -eq 0 ]]; then
        prefix="+ Executed"
        eval "$cmd"
    else
        prefix="~ Would execute"
    fi
    printf "%-100s %s\n" "$prefix command: $cmd" # "Work dir: $curr_dir"
}


# transform original github URL into something that uses our selected host
if [[ "$usercmd" =~ --clone|--fork|--submodule ]]; then
    repo_target=$(echo $repo | sed -e 's#.*github.com.\(.*\)#git@'$host':\1#g; s#/$##')
fi


if [[ "$usercmd" =~ --clone ]]; then
    cmd="git clone $repo_target"
    cmd_exec "$cmd"
fi

if [[ "$usercmd" =~ --fork|--submodule ]]; then
    upstream="$repo_target"
    origin=$(echo $upstream | sed 's#\(.*:\)\(.*\)\(/.*\)#\1'$user'\3#')
    # fork repo on github
    project=$(echo $upstream | sed 's#.*:##')
    cmd='curl -sS --user "$GITHUB_USER:$GITHUB_PASS" -X POST https://api.github.com/repos/'$project'/forks >/dev/null'
    cmd_exec "$cmd"
    if [[ "$usercmd" =~ --fork ]]; then
        # clone from user
        cmd="git clone $origin"
        cmd_exec "$cmd"
    fi
    if [[ "$usercmd" =~ --submodule ]]; then
        # add submodule
        cmd="git submodule add $origin"
        cmd_exec "$cmd"
    fi
    # add remote upstream
    local_dir=$(echo $upstream | sed 's#.*/##')
    cmd_exec "cd $local_dir"
    cmd="git remote add upstream $upstream"
    cmd_exec "$cmd"
fi


