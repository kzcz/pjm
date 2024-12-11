#!/usr/bin/env bash
set -e
read -p "Install location --> " -ei "$HOME/.pjm" LOCATION
mkdir -p $LOCATION || { echo "Couldn't create that path."; exit 1; }
install -Cvm 755 ./pjm.sh ./pjm_bash_autocomp.sh $LOCATION || { echo "Error copying files."; exit 2; }
echo "[[ -f $LOCATION/pjm.sh ]] && source $LOCATION/pjm.sh" >> $HOME/.bashrc
read -p "Projects directory? " -ei "$HOME/projects" PROJD
PS3="Enable bash autocomplete? "
select A in Yes No; do case $A in
    Yes) BAC=true; break; ;;
    No) BAC=false; break; ;;
esac; done
PS3="Enable automatic 'git init'? "
select A in Yes No; do case $A in
    Yes) AGI=true; break; ;;
    No) AGI=false; break; ;;
esac; done
echo -e "export PROJECTS_DIR=$PROJD\nexport _enable_bash_autocomp=$BAC\nexport _enable_auto_git_init=$AGI\n" > $LOCATION/settings.sh
chmod 644 $LOCATION/settings.sh
