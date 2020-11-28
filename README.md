# EWS Test-runner
![Preview of EWS Tester Result](./ews-tester.png)
For testing your code on UIUC's EWS without ssh'ing into it all the time.

This code will send you an email whenever your code is done building. This is a very bare-bones lightweight solution to allow you to easily run tess that makes use of [Aha](https://github.com/theZiz/aha), [mutt](http://www.mutt.org/), and [git hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

Because this runs on EWS, most of the programs this uses don't have to be installed manually. The only additional program you need is Aha, which is used to convert build output into nice HTML that you can read. The install script will automatically install this for you from source.

## Installation instructions

Installation is only available for macOS users (not tested), Linux users with Bash/zsh, or Windows users with Git Bash (not tested). You'll need to have SSH keys set up so that you can SSH into EWS from your personal computer. 

First, clone this repository:

```sh
git clone https://github.com/sahansk2/ews-tester.git
```

Then, `cd` into it and make necessary changes to `install.sh`. The instructions should be self-evident. If not, please open up a GitHub issue.
This install script is designed to work on your personal computer (NOT the remote).

After you are done customizing your install, run `install.sh` by running:

```sh
bash ./install.sh
```

If you don't have bash (e.g. if you're a macOS user), zsh should also work:

```sh
zsh ./install.sh
```

Once you have a successful install, download and copy the files in `worktree-repo` (`ews-tester.sh`, `job_ews-tester.sh`) to the root of 
the repo on your personal machine on which you actually want to do testing. For example, here is what my `cs296` repo looks like:

```
cs296-25-fa20
├── a_bmoore
├── a_bwt
├── a_fmi
├── a_naive
├── a_narytree
├── a_pigeon
├── a_sarray
├── a_stree
├── a_zalg
├── ews-tester.sh <------
├── job_ews-tester.sh <------
└── README.md
```

Add these files and commit, and you're done! You will 99% of the time never need to touch `ews-tester.sh`. You can control the actual commands you execute by specifying `job_ews-tester.sh`. A useful template has already been provided here. 

If you want to run tests on EWS from your local machine, if you've set up the remote as per the install script's instructions, all you have to do is run:
```
git push --force ews-tester
```
from your master branch (all tests will operate only on the master branch). Just wait a little bit, and you should get an email to your inbox!


These instructions should be clear enough for you to get going. Enjoy a life of no longer having to ssh into EWS every time you want to run tests!

## Having trouble setting up/seeing bugs?

Please open up a GitHub issue if you're having any troubles whatsoever, so that problems/suggestions can be documented cleanly. Please also considering giving a star if this script helped you. Thanks!
