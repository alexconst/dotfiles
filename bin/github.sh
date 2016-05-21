if [ "$#" -eq 0 ]; then
    printf "USAGE:\n"
    printf "\tclone\t\tclone repo using hardcoded 'github' host as defined in .ssh/config\n"
    exit 0
fi
option="$1"
url="$2"

if [ "$option" = "clone" ]; then
    target=$(echo $url | sed -e 's#.*github.com.\(.*\)#git@github:\1#g; s#/$##')
    printf "Will clone repo using URL: $target\n"
    git clone $target
fi

