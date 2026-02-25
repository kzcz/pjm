#!/usr/bin/env bash
files() {
    find $PROJECTS_DIR/ -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
}
_pjm_completion() {
    local cur prev words cword
    _init_completion || return
    [ ${COMP_CWORD} -ne 1 ] && return 0
    case ${cur} in
        /*)
            local projects=$(files)
            COMPREPLY=($(compgen -W "${projects}" -P "/" -- "${cur#/}"))
            ;;
        -*)
            local projects=$(files)
            COMPREPLY=($(compgen -W "${projects}" -P "-" -- "${cur#-}"))
            ;;
        h|l|+)
            COMPREPLY=(${cur})
            compopt -o nospace
            ;;
        *)
            COMPREPLY=($(compgen -W "h l + / -" -- "${cur}"))
            ;;
    esac
}
complete -F _pjm_completion pjm
