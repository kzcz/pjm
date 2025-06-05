#!/bin/bash
# Copyright 2024-(...) Kilzwitch Team
# Owner:        cursitical@gmail.com
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#
set -o posix
(return 0 &>/dev/null) || { printf "This file should be sourced.\n> source $0\n"; exit 1; }
PJMDIR=$(dirname "${BASH_SOURCE[0]}")
export PJM_VER="PJM 0.2.1 INDev"
_PJM_confirm () {
    echo -n "Say 'yes' to confirm >) "
    read _P_CF; [ $_P_CF = "yes" ];
    return $?
}
# settings:
source "$PJMDIR/settings.sh"
_PJM_creation_date () {
    read -r birth mod < <(stat --format='%w %z' "$1");
    ts=${birth/-/}; ts=${ts:-$mod}; ts=${ts%%.*;}
    date -d "$ts" +"%H:%M:%S (%d %B %Y)"
}
$_enable_bash_autocomp && source "$PJMDIR/pjm_bash_autocomp.sh"
[ -e $PROJECTS_DIR ] && ! [ -d $PROJECTS_DIR ] && {
    echo "$PROJECTS_DIR isn't a directory. Trying to delete it."
    _PJM_confirm && {
        rm -v $PROJECTS_DIR
        echo "Making new $PROJECTS_DIR"
        mkdir $PROJECTS_DIR
    } || echo "Aborting."; 
}

_pjm_new () {
    local proj=${PROJECTS_DIR}/$1;
    [ -z $1 ] && { echo "<name> is an empty string." >&2; return 1; }
    [ -e $proj ] && { echo "Project $1 already exists."; return 2; }
    mkdir $proj
    cd $proj
    touch LICENSE
    $_enable_auto_git_init && git init -q -b main $proj
    return 0
}
_pjm_del () {
    local proj=${PROJECTS_DIR}/$1
    [ -z $1 ] && { echo '<name> is an empty string.' >&2; return 1; }
    ! [ -e $proj ] && { echo "Project $1 doesnt exist."; return 2; }
    echo "Deleting project $1"
    _PJM_confirm && rm -rv $proj || echo "Aborting.";
    return 0
}

_pjm_cd () {
    local proj=${PROJECTS_DIR}/$1;
    [ -d $proj ] && cd $proj || { 
        [ -e $proj ] && { 
            echo "$proj is not a directory."; return 1;
        } || { 
            echo "Project $proj doesnt exist."; return 2;
        };
    };
    return 0
}
_pjm_list () {
    local _list="";
    local list=();
    (( $# > 1 )) && _list="$@" || {
        local e="";
        _list="$(ls $PROJECTS_DIR)";
        [ -n "$1" ] && {
            { [ -e "$PROJECTS_DIR/$1" ] && [ "$1" != "." ] && [ "$1" != ".." ]; } && e="e";
            { [ -z "$1" ] || [ -z "$e" ]; } && { _list="$(grep -iEe "$1" <<< "$_list")"; [ -n "$_list" ] && echo "No exact match, using grep." || { echo "No match found."; return 1; }; };
            [ -n "$e" ] && _list="$1";
        }
    }
    for i in $_list; do
        [ -e "$PROJECTS_DIR/$i" ] && list+=($i) || printf $'\e[1;37m%s\e[0m doesn\'t exist, skipping.\n' $i; 
    done;
    local longest=$(echo "${list[@]}" | tr " " "\n" | awk '{print length,$0}' | sort -nr | head -1 | cut -d\  -f1)
    out=()
    for i in "${list[@]}"; do
        real="$PROJECTS_DIR/$i";
        l=$(wc -c <<< $i)
        l=$(( longest - l + 3 ))
        out+=("$(printf $'\e[1;37m%s\e[0m%*s%s\n' $i $l '' "- $(_PJM_creation_date $real)")")
    done;
    printf '%s\n' "${out[@]}"
}
pjm () {
    [ -z "$*" ] || [ "$#" -ge 2 ] && { echo "Usage: pjm [Prefix][args]"; return 1; }
    local _P0=${1:0:1};
    local _P1=${1:1};
    case $_P0 in
        /)
            _pjm_cd $_P1; return $?
            ;;
        -)
            _pjm_del $_P1; return $?
            ;;
        +)
            _pjm_new $_P1; return $?
            ;;
        l)
            _pjm_list $_P1; return $?
            ;;
        h)
            printf \
"Copyright 2024-(...) Kilzwitch Team.\n"\
"Version: $PJM_VER\n"\
"    +<name>        = creates a new project.\n"\
"    /[name]        = changes directory into a project (PROJECTS_DIR if no name).\n"\
"    -<name>        = deletes a project.\n"\
"    l[name[s ...]] = list select projects, if none is selected, list them all.\n"\
"    l<regex>       = find projects using regex, and list them.\n"\
"    h       = prints this message.\n"
            return 0
            ;;
        *)
            echo "Invalid prefix.";
            echo "Try pjm h";
            return 4;
            ;;
    esac
    return 0;
}

