###########################################################
# ALIAS
###########################################################

# clear some annoying prezto aliases (for more check https://github.com/sorin-ionescu/prezto/blob/master/modules/utility/init.zsh )
unalias ls

# work around some of prezto annoyances/bugs
unfunction diff


# list alphabetically
alias l='ls -la --color=always --time-style=long-iso'
# list by grouping dotfiles and use natural numeric sort
alias ll='ls -la -v --color=always --full-time --group-directories-first'

alias lir='less -i -r'
alias less='less -i'

