#!/bin/bash

echo "Xan's dotfile installer"
echo "-----------------------"
echo ""

echo "Installing Config Files..."

for CONFIG in _* ; do
	echo "Copying ${CONFIG} to ${HOME}/.${CONFIG:1}"
	cp "${CONFIG}" "${HOME}/.${CONFIG:1}"
done

echo ""
echo "Copied dotfiles to ${HOME}."
echo ""

read -p "What is your git username? [$(whoami)]: " gituser

if [ ${#gituser} -lt 2 ] ; then
	gituser="$(whoami)"
fi

sed -i "s/name =$/name = ${gituser}/" ~/.gitconfig


read -p "What is your git email? [$(whoami)@$(hostname)]: " gitmail

if [ ${#gitmail} -lt 2 ] ; then
	gitmail="$(whoami)@$(hostname)"
fi

sed -i "s/email =$/email = ${gitmail}/" ~/.gitconfig

echo ""
echo "Writing to git config..."
echo ""

echo ""
echo "Done"
