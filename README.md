# autosaver
autosaver script to keep track of various dotfiles and backup files around my OS

## how to use
- create a new repository
- copy `.gitignore` and `autosaver.sh` files into repository
- run once `./autosaver.sh` to create user config files
- manually edit `userconfig/user_branch.txt` to contain the name of the whitelisted branch 
- run once `./autosaver.sh` to create all needed files

## how to move a repo
- move `config` and `init` directories into the new repo
- edit file `userconfig/user_branch.txt` to contain the name of the whitelisted branch in the new repo

### known problems
- if user changes, it's necessary to manually edit `config/file_to_track.txt` and manually move files in backup directory
