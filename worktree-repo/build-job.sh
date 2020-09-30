#!/bin/bash
### Source envs here.
. build-job.cfg
git show -s --format=oneline
echo "========================"
echo

### DON'T CHANGE ME
# PS4="\n\033[1;33m>>>\033[0m "
# set -x

### Add build job instructions below.
module load llvm/6.0.1
cd $BUILD_FOLDER
make clean
make $BUILD_BINARY
./$BUILD_BINARY

