#!/bin/bash
echo ""
echo ""
echo "Xan's dotfile installer"
echo "-----------------------"
echo ""

ISGITCONF=false
GITVERSION=$(git --version | awk '{ print $3 }' | awk -F. '{ print $1 }')

if [ ${#} -gt 0 ] ; then
	TIDYLIST=$(echo "${@}" | sed -e "s/ /, /g")

	echo "Installing config files (${TIDYLIST})..."

	for arg in "${@}" ; do
		if [ "${arg}" == "gitconfig" ] ; then
			ISGITCONF=true

			if [ "${GITVERSION}" == "1" ] ; then
				TIMESTAMP=$(date +%s)
				cp "${HOME}/.${arg}" "${HOME}/${arg}-${TIMESTAMP}.backup"
			fi
		fi

		if [ -r "_${arg}" ] ; then
			echo "Copying _${arg} to ${HOME}/.${arg}"
			cp "_${arg}" "${HOME}/.${arg}"
		else
			echo "Could not find _${arg}"
		fi
	done
else
	echo "Installing all config files..."
	ISGITCONF=true

	for CONFIG in _* ; do
		echo "Copying ${CONFIG} to ${HOME}/.${CONFIG:1}"
		cp "${CONFIG}" "${HOME}/.${CONFIG:1}"
	done

	echo ""
	echo "Copied dotfiles to ${HOME}."
	echo ""
fi

if ${ISGITCONF} ; then
	if [ "${GITVERSION}" == "1" ] ; then
		echo ""
		echo "WARNING: this git config uses features from Git 2.0+"
		echo "You may experience unexpected behavior with git pull."
		echo ""
	fi

	read -p "What is your git username? [$(whoami)]: " gituser

	if [ ${#gituser} -lt 2 ] ; then
		gituser="$(whoami)"
	fi

	if [ "$(uname)" = "Darwin" ] ; then
		sed -i "" "s/name =$/name = ${gituser}/" ~/.gitconfig
	else
		sed -i "s/name =$/name = ${gituser}/" ~/.gitconfig
	fi

	read -p "What is your git email? [$(whoami)@$(hostname)]: " gitmail

	if [ ${#gitmail} -lt 2 ] ; then
		gitmail="$(whoami)@$(hostname)"
	fi

	if [ "$(uname)" = "Darwin" ] ; then
		sed -i "" "s/email =$/email = ${gitmail}/" ~/.gitconfig
	else
		sed -i "s/email =$/email = ${gitmail}/" ~/.gitconfig
	fi

	echo ""
	echo "Writing to git config..."
	echo ""
fi

echo ""
echo "Done"
