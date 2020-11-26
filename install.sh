#!/bin/bash

# ===================================================================================

# ============== REQUIRED ================
# Server that you SSH to.
REMOTE_SERVER="netid2@cs225-remote.ews.illinois.edu" 

# Email address to which you would like notifications.
EWS_TEST_RECIPIENT="netid2@illinois.edu" 

# Cloneable URL for your repo. 
REMOTE_SRC='git@github-dev.cs.illinois.edu:cs296-25-fa20/netid2.git'

# ============== OPTIONAL ================
# Installation location of the testing repo.
CLONE_LOCATION="" # Default is ~/.ews-tester/$REPO

# Installation path for aha
AHA_INSTALL="" # Default is ~/.local/, binary will be located in $AHA_INSTALL/bin


# ===================================================================================
ssh $REMOTE_SERVER AHA_INSTALL=$AHA_INSTALL REMOTE_SRC=$REMOTE_SRC REMOTE_SERVER=$REMOTE_SERVER EWS_TEST_RECIPIENT=$EWS_TEST_RECIPIENT REPO=$REPO 'bash -s' <<"ENDSSH"
RED='\033[1;31m'
PURPLE='\033[1;35m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

print_warn() {
    printf "$YELLOW$1$NC\n"
}

print_error() {
    printf "$RED$1$NC\n"
}

print_tip() {
    printf "$PURPLE$1$NC\n"
}

print_success() {
    printf "$GREEN$1$NC\n"
}

if [[ -z "$REMOTE_SRC" ]]; then
    print_error "You haven't specified \$REMOTE_SRC. Please do so."
    exit 1
fi

if [[ -z "$REPO" ]]; then
    if [[ $REMOTE_SRC = git@* ]]; then
        REPO=$(echo $REMOTE_SRC | cut -d ":" -f2 | cut -d "." -f1)
    elif [[ $REMOTE_SRC = http* ]]; then
        REPO=$(echo $REMOTE_SRC | awk -F'/' '{ print $(NF-1)"/"$NF }' | cut -d "." -f1)
    else
        print_error "You have not specified the repo name, and it cannot be inferred from \$REMOTE_SRC."
        exit 1
    fi
fi

# Set reasonable defaults
if [[ -z "$CLONE_LOCATION" ]]; then
    CLONE_LOCATION=$(echo "$REPO" | cut -d "/" -f1)
    CLONE_LOCATION="$HOME/.ews-tester/$CLONE_LOCATION"
fi

if [[ -z "$AHA_INSTALL" ]]; then
    AHA_INSTALL="$HOME/.local"
fi

if [ ! -f "$AHA_INSTALL/bin/aha" ]; then
    TEMPDIR="/tmp/aha-$(whoami)-$(date +%s)"
    print_warn "aha installation not detected; we'll try to install it for you."
    print_tip "temporary build directory is $TEMPDIR."
    git clone https://github.com/theZiz/aha.git $TEMPDIR
    cd $TEMPDIR
    make install PREFIX=$AHA_INSTALL
    unset TEMPDIR
fi

if [ ! -f "$AHA_INSTALL/bin/aha" ]; then
    print_error "Installation of aha unsuccessful! Aborting..."
    print_error "You may need to install aha and put it in your \$PATH somehow."
    exit 1
fi

command -v aha > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    print_warn "aha not found in \$PATH!"
    print_tip "We will try to add it to your path for you."
    echo "export PATH=$AHA_INSTALL/bin/:\$PATH" >> ~/.bashrc
    source ~/.bashrc
fi

cd

if [ -d "$CLONE_LOCATION" ]; then
    if [ -d "$CLONE_LOCATION/.git" ]; then
        print_warn "Assuming that you cloned this directory manually. Continuing..."
    else
        print_error "Error! The directory you're trying to clone to is nonempty and also not a git directory."
        exit 1
    fi
else
    git clone $REMOTE_SRC $CLONE_LOCATION
fi

if [ ! -d "$CLONE_LOCATION" ]; then
    print_error "Something happened when trying to clone from remote."
    print_error "Either your SSH key is invalid, or it's password protected and cannot be filled in remotely."
    print_tip "Try cloning your repository manually, and then running this install script one more time."
    print_tip "The command you should run is:\n"
    print_tip "\t git clone $REMOTE_SRC $CLONE_LOCATION\n"
    print_tip "If that doesn't work, try cloning using HTTPS and supplying your username/password manually."
    exit 1
fi

cd $CLONE_LOCATION

git checkout -b @standby

POST_RECEIVE="$CLONE_LOCATION/.git/hooks/post-receive"

if [ -f $POST_RECEIVE ]; then
    rm $POST_RECEIVE
fi

touch "$POST_RECEIVE"
chmod +x "$POST_RECEIVE"
echo "export GIT_DIR=$CLONE_LOCATION/.git" >> "$POST_RECEIVE"
echo "export GIT_WORK_TREE=$CLONE_LOCATION" >> "$POST_RECEIVE"
echo "export RECIPIENT=$EWS_TEST_RECIPIENT" >>  "$POST_RECEIVE"
echo "export REPO=$REPO" >> "$POST_RECEIVE"
echo 'git checkout master' >> "$POST_RECEIVE"
echo 'echo -e "\033[1;32m EWS-Tester is launching on $REPO. \033[0m"' >> "$POST_RECEIVE"
echo "export GIT_WORK_TREE=$CLONE_LOCATION"  >> "$POST_RECEIVE"
echo 'echo "bash $GIT_WORK_TREE/ews-tester.sh" | at -M now' >> "$POST_RECEIVE"

print_success "Successfully gone through install procedure!"
print_tip "Please add the install directory as a remote, so that you can push to it:\n"
print_tip "\tgit remote add ews-tester $REMOTE_SERVER:$CLONE_LOCATION\n"
print_tip "Force pushing is strongly recommended so that you don\'t worry about merge conflicts."
print_tip "Please configure your build-job.cfg, gitmail.cfg, and build-job.sh to your liking now."
ENDSSH
