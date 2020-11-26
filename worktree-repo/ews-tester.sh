#!/bin/bash

main() {
ews_tester_setup

# ================== ews_tester commands ===============
HASH=$(git rev-parse --short HEAD)
MESSAGE=$(git log -n 1 --pretty=format:%s)
script -efq /dev/null -c "./job_ews-tester.sh" | aha -x > output.html

log_message "Sending mail"
mutt -e 'set content_type=text/html' \
	-s "$REPO@$HASH: Build \"$MESSAGE\" finished." \
	"$RECIPIENT" < output.html
# =======================================================

ews_tester_cleanup
}

# ================== support functions =================

log_message() {
    echo "[INFO:ews-tester] $1"
}

trap "log_message 'Something bad happened!'" SIGHUP

ews_tester_setup () {
log_message "Running setup"
log_message "Sourcing required env"
export TERM=xterm-color
source /etc/profile
source $HOME/.bashrc
source $HOME/.bash_profile

cd $(dirname $BASH_SOURCE)
git checkout --force master
log_message "Running job"
}

ews_tester_cleanup () {

log_message "Deleting artifacts"
rm -f output.txt output-bin.txt output.html
git checkout --force @standby

}

main
