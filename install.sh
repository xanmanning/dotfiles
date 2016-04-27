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
		if [ "${arg:0:1}" == "_" ] ; then
			argf=${arg:1}
		else
			argf=${arg}
		fi

		if [ "${argf}" == "gitconfig" ] ; then
			ISGITCONF=true

			if [ "${GITVERSION}" == "1" ] ; then
				TIMESTAMP=$(date +%s)
				cp "${HOME}/.${argf}" "${HOME}/${argf}-${TIMESTAMP}.backup"
			fi
		fi

		if [ -r "_${argf}" ] ; then
			echo "Copying _${argf} to ${HOME}/.${argf}"

			if [ -f "_${argf}" ] ; then
				cp "_${argf}" "${HOME}/.${argf}"
			fi

			if [ -d "_${argf}" ] ; then
				if [ "${argf: -1}" == "/" ] ; then
					argdf=${argf:0:-1}
				else
					argdf=${argf}
				fi

				if [ ! -d "${HOME}/.${argdf}/" ] ; then
					mkdir "${HOME}/.${argdf}/"
				fi

				rsync -arvl "_${argdf}/" "${HOME}/.${argdf}/"
			fi
		else
			echo "Could not find _${argf}"
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
