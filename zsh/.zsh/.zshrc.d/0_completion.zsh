###########################################################
# GLOB AND ZSTYLE COMPLETION
###########################################################

# enable hidden/dot files completion
# https://unix.stackexchange.com/questions/89749/cp-hidden-files-with-glob-patterns
# https://unix.stackexchange.com/questions/22571/how-to-fix-tab-completion-so-it-doesnt-hide-entries
setopt dotglob



# auto rehash
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1  # Because we didn't really complete anything
}
zstyle ':completion:*' completer \
    _oldlist _expand _force_rehash _complete _match _approximate


# overwrite prezto settings to support completion for functions starting with two underscores
zstyle ':completion:*:functions' ignored-patterns '(_[^_]*|pre(cmd|exec))'

