#!/bin/bash
# Copyright 2024 Kilzwitch Team
# Owner:        cursitical@gmail.com
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#
set -o posix
(return 0 &>/dev/null) || { printf "This file should be sourced.\n> source $0\n"; exit 1; }

export PJM_VER="PJM 0.1 INDev"
_PJM_confirm () {
    echo -n "Say 'yes' to confirm >) "
    read _P_CF; [ $_P_CF == "yes" ];
    return $?
}
# settings:
export PROJECTS_DIR=$HOME/projects
_enable_bash_autocomp=true

$_enable_bash_autocomp && source "$(dirname "${BASH_SOURCE[0]}")/pjm_bash_autocomp.sh"
[ -e $PROJECTS_DIR ] && ! [ -d $PROJECTS_DIR ] && {
    echo "$PROJECTS_DIR isn't a directory. Trying to delete it."
    _PJM_confirm && {
        rm -v $PROJECTS_DIR
        echo "Making new $PROJECTS_DIR"
        mkdir $PROJECTS_DIR
    } || echo "Aborting."; 
}

pjm_new () {
    local proj=${PROJECTS_DIR}/$1;
    [ -z $1 ] && { echo "<name> is an empty string." > 2; return 1; }
    [ -e $proj ] && { echo "Project $1 already exists."; return 2; }
    mkdir $proj;
    cd $proj;
    touch LICENSE;
    return 0;
}
pjm_del () {
    local proj=${PROJECTS_DIR}/$1;
    [ -z $1 ] && { echo '<name> is an empty string.' > 2; return 1; }
    ! [ -e $proj ] && { echo "Project $1 doesnt exist."; return 2; }
    echo "Deleting project $1";
    _PJM_confirm && rm -rv $proj || echo "Aborting.";
    return 0
}

pjm_cd () {
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
pjm () {
    [ -z "$*" ] || [ "$#" -ge 2 ] && { echo "Usage: pjm [Prefix][args]"; return 1; }
    local _P0=${1:0:1};
    local _P1=${1:1};
    case $_P0 in
        /)
            pjm_cd $_P1; return $?
            ;;
        -)
            pjm_del $_P1; return $?
            ;;
        +)
            pjm_new $_P1; return $?
            ;;
        h)
            printf \
"Copyright 2024 Kilzwitch Team.\n"\
"Version: $PJM_VER\n"\
"    +<name> = creates a new project.\n"\
"    /[name] = changes directory into a project (PROJECTS_DIR if no name).\n"\
"    -<name> = deletes a project.\n"\
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

