# References:
#######################################
# zsh vi mode
# http://dougblack.io/words/zsh-vi-mode.html
# https://github.com/dougblack/dotfiles/blob/master/.zshrc
# http://superuser.com/questions/351499/how-to-switch-comfortably-to-vi-command-mode-on-the-zsh-command-line
# NOTE: behavior differs in zsh >= 5.0.8 which supports vim style text objects.
#   the implication is that things like daw or diw will not work with previous zsh
#   unless you use a work around like the one described in http://unix.stackexchange.com/questions/116172/how-to-enable-daw-vi-command-in-zsh
# other references that could be useful:
# http://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode
# https://github.com/Osse/dotfiles/blob/master/.zshrc#L124-L203
# NOTE: with the vi bindings pressing the up/down arrow keys puts the cursor at the BOL, to get the cursor at the EOL use ctrl+p/ctrl+n
#
# https://github.com/sorin-ionescu/prezto/pull/963
#######################################


# use jj for Esc
bindkey -M viins 'jj' vi-cmd-mode
# timeout is being set somewhere else to 40 (and it works fine)
#export KEYTIMEOUT=20

# some compatibility because old habits die hard
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
# navigate history with vi bindings
bindkey '^P' up-history
bindkey '^N' down-history
# backspace and ^h working even after returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
# delete and insert keys in insert mode
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[kich1]}" insert-char
# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward


# fix navigation keys in vi mode
# http://www.zsh.org/mla/users/2010/msg00053.html
# https://bbs.archlinux.org/viewtopic.php?pid=878393#p878393
# http://zshwiki.org/home/zle/bindkeys
# https://bbs.archlinux.org/viewtopic.php?id=151738
if [[ -n ${terminfo[smkx]} ]] && [[ -n ${terminfo[rmkx]} ]]; then
    zle-line-init() { echoti smkx; }
    zle-line-finish() { echoti rmkx; }
    zle -N zle-line-init
    zle -N zle-line-finish
    bindkey     "$terminfo[khome]"      vi-beginning-of-line
    bindkey     "$terminfo[kend]"       vi-end-of-line
fi


