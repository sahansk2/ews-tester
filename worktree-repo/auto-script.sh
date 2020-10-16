#!/bin/bash

# DO NOT INVOKE DIRECTLY. There are a lot of environment variables not set.

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
export TERM=xterm-color
source /etc/profile
source $HOME/.bashrc
source $HOME/.bash_profile
# tr -d '[\015\200-\377]' < output-bin.txt > output.txt

log_message "Running job"
source ./build-job.cfg
# ./build-job.sh > out.esc 2>&1 
script -efq /dev/null -c "./build-job.sh" | aha -x > output.html
ERROR_CODE=$?
# cat out.esc | sed 's/\x1b\[[0-9;]*m//g' > output.txt
# cat out.esc | aha > output.html

log_message "Sending mail"
source gitmail.cfg
mutt -e 'set content_type=text/html' \
	-s "$REPO@$HASH: Build \"$BUILD_NAME\" exit code: $ERROR_CODE" \
	"$RECIPIENT" < output.html
# mail -s "$(echo -e \nContent-Type: text/html")" $RECIPIENT < ./output.html

log_message "Deleting artifacts"
rm -f output.txt output-bin.txt output.html

