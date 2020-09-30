#!/bin/bash

LOG_FILE="$HOME/log.txt"
HASH=$(git rev-parse --short HEAD)
REPO=$(git config --get remote.origin.url | cut -d ":" -f2 | cut -d "." -f1)
# Set up logging
log_message() {
    echo "[INFO:auto-script] $1"
    echo "$1" >> "$LOG_FILE"
}

trap "log_message 'Something bad happened!'" SIGHUP

log_message "Running setup"
GIT_WORK_TREE=$(realpath $GIT_DIR/..)
cd $GIT_WORK_TREE


log_message "Sourcing required env"
source /etc/profile
source $HOME/.bashrc
source $HOME/.bash_profile


# tr -d '[\015\200-\377]' < output-bin.txt > output.txt

log_message "Running job"
source ./build-job.cfg
./build-job.sh > out.esc 2>&1 
ERROR_CODE=$?
cat out.esc | sed 's/\x1b\[[0-9;]*m//g' > output.txt
cat out.esc | aha > output.html

log_message "Sending mail"
source gitmail.cfg
mail -s "$REPO@$HASH: Build \"$BUILD_NAME\" completed with exit code: $ERROR_CODE" $RECIPIENT < ./output.txt

log_message "Deleting artifacts"
rm -f output.txt output-bin.txt output.html

