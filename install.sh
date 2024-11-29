#!/usr/bin/env bash
set -e
read -t 5 -p "Install location --> " -ei "$HOME/pjm" LOCATION
mkdir -p $LOCATION || { echo "Couldn't create that path."; exit 1; }
cp ./pjm.sh ./pjm_bash_autocomp.sh $LOCATION || { echo "Error copying files."; exit 2; }
chmod 0744 $LOCATION/pjm.sh $LOCATION/pjm_bash_autocomp.sh
echo "[[ -f $LOCATION/pjm.sh ]] && source $LOCATION/pjm.sh" >> $HOME/.bashrc
