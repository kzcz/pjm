#!/usr/bin/env bash
set -e
die() { echo "$1"; exit "${2:-1}"; }
[[ -z "$BASH_VERSION$ZSH_VERSION" ]] && die "Unsupported shell. Try again with zsh or bash.";
: # "ask <prompt> <default value> <where to store the result>"
[[ -n "$BASH_VERSION" ]] && { EXT="sh"; OUTF="$HOME/.bashrc"; } || { EXT="zsh"; OUTF="$HOME/.zshrc"; };
PJM_FILE="pjm.$EXT"
ask() {
    if [[ -n "$BASH_VERSION" ]]; then
        read -p "$1" -ei "$2" "$3"
    else
        typeset -g "$3=$2"
        vared -ep "$1" "$3" || typeset -g "$3=$2"
    fi
}
yno() {
    local O
    PS3="$2"
    select A in Yes No; do case $A in Yes) O=true; break; ;; No) O=false; break; ;; esac; done
    typeset -g "$1=$O"
}
ask "Install location --> " "$HOME/.pjm" LOCATION
if [[ -e "$LOCATION" ]]; then
    [[ -d "$LOCATION" ]] || die "Path exists and is not a directory"
else
    mkdir -p $LOCATION || die "Couldn't create that path.";
fi
install -Cvm 755 "./$PJM_FILE" "./pjm_comp.$EXT" $LOCATION || die "Error copying files." 2
echo "[[ -f $LOCATION/$PJM_FILE ]] && source $LOCATION/$PJM_FILE" >> "$OUTF"
ask "Projects' directory? " "$HOME/projects" PROJD
yno COMP "Enable autocompletion? "
yno AGI "Enable automatic 'git init'? "
echo -e "export PROJECTS_DIR=\"$PROJD\"\nexport _enable_comp=\"$COMP\"\nexport _enable_auto_git_init=\"$AGI\"\n" > $LOCATION/settings.sh
chmod 644 $LOCATION/settings.sh
source "./$PJM_FILE"
source $LOCATION/settings.sh
