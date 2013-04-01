#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White

################################################################
#Utility function to print color echo messages
# Arg $1 = message
# Arg $2 = color
# ex. __color_echo "Test" $echo_red
################################################################
color_echo() {
   local default_msg="No message passed." # Doesn't really need to be a local variable.
   message=${1:-$default_msg} # Defaults to default message.
   color=${2:-$bldwht} # Defaults to black, if not specified.

   #Set color
   echo -ne "$color"
   echo "$message"
   #Reset to normal.
   tput sgr0 

   return
}

heading() {
   color_echo "$1" $bldblu
}

info() {
   color_echo "$1" $bldgrn
}

error() {
   color_echo "$1" $bldred
}

############################
# Variables
############################
date="$(date +"%Y%m%d-%H%M%S")"
dotfile_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #dotfile directory
backup_dir=$HOME/.dotfiles.backup/$date # old dotfiles backup directory
files="$( for i in $(find $dotfile_dir -name ".*" -type f); do basename $i; done | grep -v '^\.git$' )"
heading "Files managed by this script:"
for file in $files; do 
   info "   $file"
done

############################
# create backup dir 
############################
echo ""
heading "Creating $backup_dir for backup of any existing dotfiles"
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
      info "   Exiting..."
      exit 0;
   fi

   info "   Deleting existing directory $backup_dir"
   rm -rf $backup_dir
fi
mkdir -p $backup_dir
info "   Created backup directory $backup_dir"

############################
# backup existing files, setup our links
############################
for file in $files; do
   dotfile_file="$dotfile_dir/$file"
   backup_file="$backup_dir/$file"
   original_file="$HOME/$file"
   echo ""
   heading "Processing $file:"
   skip=0
   if [ -e $original_file ]; then
      if [ -h $original_file ]; then
         linked_to="$(readlink $original_file)"
         info "   File $original_file is a symlink to $linked_to"
         if [ "$linked_to" == "$dotfile_file" ]; then
            info "   Skipping $original_file since it is already a symlink to $dotfile_file"
            skip=1
         else
            info "   Copying \"pointed to\" file $linked_to to $backup_file"
            cp $linked_to $backup_file
            info "   Removing symlink from $original_file -> $linked_to"
            rm $original_file
         fi
      else
         info "   Moving $original_file to $backup_file"
         mv $original_file $backup_file
      fi
   else
      info "   Skipping backup of $original_file since it doesn't exist"
   fi

   if [ "$skip" -ne 1 ]; then
      info "   Creating symlink from $original_file -> $dotfile_file"
      ln -s $dotfile_file $original_file
   fi
done

############################
# make sure vundle is installed
############################
vundle_dir="$HOME/.vim/bundle/vundle"
echo ""
heading "Making sure a version of Vundle is installed to $vundle_dir"
skip=0
if [ -e "$vundle_dir" ]; then
   info "   Vundle is already installed at $vundle_dir"
else
   #We could also stick a version in our dotfiles folder and copy it over
   #But don't link it, I don't think we want to change it in git )
   info "   Cloning vundle from git into $vundle_dir"
   git clone http://github.com/gmarik/vundle.git $vundle_dir
   ret=$?
   if [ "$?" -eq "0" ]; then
      info "   Cloning vundle successfull"
   else
      error "   Something went wrong cloning vundle, please check installation"
      skip=1
   fi
fi
if [ "$skip" -ne 1 ]; then
   info "   Updating bundles in vim by running: vim -c BundleInstall! -c BundleClean! -c quitall!"
   vim -c BundleInstall! -cBundleClean! -c quitall!
fi

#TODO Add support for deeper vim sync'ing ( ftplugin, UltiSnips, etc... )
#This could also be done by making those github folders for non-work sensitive stuff
