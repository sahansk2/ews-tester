#!/bin/bash

# ===== Define your useful variables here =====
# If you're in CS225 or CS296-25, then you can just change the folder of the current
# MP and then put the name of the binary you want to test,
# and leave everything as is. Thanks, course staff, for standardizing this!

BUILD_FOLDER="a_naive"
BUILD_BINARY="test"
# =============================================

# Just some commands to show your commit.
git show -s --format=oneline
echo "========================"
echo

# ===== Define your actual testing here. =====
module load llvm/6.0.1 # load clang++ 
cd $BUILD_FOLDER # cd into current MP folder
make -s clean # remove old build files 
make -s $BUILD_BINARY # generate new build file from scratch
time ./$BUILD_BINARY # run the build file and time it
# =============================================