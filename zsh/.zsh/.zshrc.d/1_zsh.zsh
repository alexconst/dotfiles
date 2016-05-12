# these settings are already defined in prezto module/history
## history file
#HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
## history size
#HISTSIZE=10000
## save history
#SAVEHIST=10000

# append history
setopt appendhistory
# ignore dupes
setopt histignorealldups
# history will be saved after every command you run (good for when power failures happen)
setopt incappendhistory
# ignore commands that start with a leading space
setopt histignorespace

# fix prezto annoyance
unsetopt share_history

# allow comments (lines starting with #) when using an interactive shell
setopt interactivecomments


# output format for the time command
TIMEFMT=$'> %J\n>   %U user, %S system, %P cpu, %*E total'


