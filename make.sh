#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

############################
# Variables
############################
date="$(date +%Y%m%d)"
dotfile_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #dotfile directory
backup_dir=$HOME/dotfiles_old/$date # old dotfiles backup directory
files="$( for i in $(find $dotfile_dir -name ".*" -type f); do basename $i; done | grep -v '^\.git$' )"
echo "Files managed by this script:"
for file in $files; do 
   echo "   $file"
done


############################
# create backup dir 
############################
echo ""
echo "Creating $backup_dir for backup of any existing dotfiles"
if [ -e $backup_dir ]; then
   answer=""
   while [ "$answer" == "" ]; do
      read -n 1 -p "   Backup directory $backup_dir already exists, do you want to delete it? [y/n]: " answer

      if [ "$answer" == "Y" -o "$answer" == "y" ]; then
         answer='y'
      elif [ "$answer" == "N" -o "$answer" == "n" ]; then
         answer='n'
      else
         answer=''
      fi

   done
   printf "\n"

   if [ "$answer" == "n" ]; then
      echo "   Exiting..."
      exit 0;
   fi

   echo "   Deleting existing directory $backup_dir"
   rm -rf $backup_dir
fi
mkdir -p $backup_dir
echo "   Created backup directory $backup_dir"

############################
# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
############################
for file in $files; do
   dotfile_file="$dotfile_dir/$file"
   backup_file="$backup_dir/$file"
   original_file="$HOME/$file"
   echo ""
   echo "Processing $file:"
   if [ -e $original_file ]; then
      echo "   Moving $original_file to $backup_file"
      mv $original_file $backup_file
   else
      echo "   Skipping backup of $original_file since it doesn't exist"
   fi

   echo "   Creating symlink from $original_file -> $dotfile_file"
   ln -s $dotfile_file $original_file
done
