#!/usr/bin/env bash

_pjm_completion() {
    local cur prev words cword
    _init_completion || return

    # If we're not at the first argument, no completion
    [ ${COMP_CWORD} -ne 1 ] && return 0

    case ${cur} in
        /*)
            local projects=$(cd "${PROJECTS_DIR}" && ls -d */ 2>/dev/null | sed 's#/##')
            COMPREPLY=($(compgen -W "${projects}" -P "/" -- "${cur#/}"))
            ;;
        -*)
            local projects=$(cd "${PROJECTS_DIR}" && ls -d */ 2>/dev/null | sed 's#/##')
            COMPREPLY=($(compgen -W "${projects}" -P "-" -- "${cur#-}"))
            ;;
        h)
            COMPREPLY=('h')
            compopt -o nospace
            ;;
        +)
            COMPREPLY=('+')
            compopt -o nospace
            ;;
        *)
            COMPREPLY=($(compgen -W "h + / -" -- "${cur}"))
            ;;
    esac
}

# Register the completion function
complete -F _pjm_completion pjm
