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
backup_dir=$HOME/dotfiles.old/$date # old dotfiles backup directory
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
# backup existing files, setup our links
############################
for file in $files; do
   dotfile_file="$dotfile_dir/$file"
   backup_file="$backup_dir/$file"
   original_file="$HOME/$file"
   echo ""
   echo "Processing $file:"
   skip=0
   if [ -e $original_file ]; then
      if [ -h $original_file ]; then
         linked_to="$(readlink $original_file)"
         echo "   File $original_file is a symlink to $linked_to"
         if [ "$linked_to" == "$dotfile_file" ]; then
            echo "   Skipping $original_file since it is already a symlink to $dotfile_file"
            skip=1
         else
            echo "   Copying \"pointed to\" file $linked_to to $backup_file"
            cp $linked_to $backup_file
            echo "   Removing symlink from $original_file -> $linked_to"
            rm $original_file
         fi
      else
         echo "   Moving $original_file to $backup_file"
         mv $original_file $backup_file
      fi
   else
      echo "   Skipping backup of $original_file since it doesn't exist"
   fi

   if [ "$skip" -ne 1 ]; then
      echo "   Creating symlink from $original_file -> $dotfile_file"
      ln -s $dotfile_file $original_file
   fi
done

############################
# make sure vundle is installed
############################
vundle_dir="$HOME/.vim/bundle/vundle"
echo ""
echo "Making sure a version of Vundle is installed to $vundle_dir"
skip=0
if [ -e "$vundle_dir" ]; then
   echo "   Vundle is already installed at $vundle_dir"
else
   #We could also stick a version in our dotfiles folder and copy it over
   #But don't link it, I don't think we want to change it in git )
   echo "   Cloning vundle from git into $vundle_dir"
   git clone http://github.com/gmarik/vundle.git $vundle_dir
   ret=$?
   if [ "$?" -eq "0" ]; then
      echo "   Cloning vundle successfull"
   else
      echo "   Something went wrong cloning vundle, please check installation"
      skip=1
   fi
fi
if [ "$skip" -ne 1 ]; then
   echo "   Updating bundles in vim by running: vim -c BundleInstall! -c quitall!"
   vim -c BundleInstall! -c quitall!
fi
