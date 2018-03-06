#!/usr/bin/env bash
echo ""
echo ""
echo "Xan's dotfile installer"
echo "-----------------------"
echo ""

set -eu

ISGITCONF=false
ISMUTTCONF=false
ISBASHCONF=false
TTYORIG=$(stty -g)
GITVERSION=$(git --version | awk '{ print $3 }' | awk -F. '{ print $1 }')
BACKUPDIR="${HOME}/.config_backup/$(date +%s)"
LONG_HOSTNAME=$(hostname)
SHORT_HOSTNAME=$(echo ${LONG_HOSTNAME} | awk -F. '{ print $1 }')

echo "Creating backup directory: ${BACKUPDIR}"
mkdir -p ${BACKUPDIR}

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

        if [ "${argf}" == "muttrc" ] ; then
            if [ "$(uname)" != "Darwin" ] ; then
                ISMUTTCONF=true
            fi
        fi

        if [ "${argf}" == "bashrc" ] ; then
            ISBASHCONF=true
        fi

        if [ -r "_${argf}" ] ; then
            echo "Copying _${argf} to ${HOME}/.${argf}"

            if [ -f "_${argf}" ] ; then
                if [ -f "${HOME}/.${argf}" ] ; then
                    cp "${HOME}/.${argf}" "${BACKUPDIR}/_${argf}"
                fi

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
                else
                    cp -r "${HOME}/.${argdf}" "${BACKUPDIR}/_${argdf}"
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
    ISBASHCONF=true

    if [ "$(uname)" != "Darwin" ] ; then
        ISMUTTCONF=true
    fi

    for CONFIG in _* ; do
        if [ -r "${HOME}/.${CONFIG:1}" ] ; then
            cp -r "${HOME}/.${CONFIG:1}" \
                "${BACKUPDIR}/${CONFIG}"
        fi

        echo "Copying ${CONFIG} to ${HOME}/.${CONFIG:1}"

        if [ -f "${CONFIG}" ] ; then
            cp "${CONFIG}" "${HOME}/.${CONFIG:1}"
        fi

        if [ -d "${CONFIG}" ] ; then
            if [ ! -d "${HOME}/.${CONFIG:1}" ] ; then
                mkdir -p "${HOME}/.${CONFIG:1}"
            fi

            rsync -arvl "${CONFIG}/" "${HOME}/.${CONFIG:1}"
        fi
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

    echo ""
    echo "[.gitconfig settings]"
    echo ""
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

if ${ISMUTTCONF} ; then
    echo ""
    echo "[.muttrc config]"
    echo ""

    NOVALIDPASS=0

    echo "Creating ~/.mutt directory"
    if [ ! -d ~/.mutt ] ; then
        mkdir ~/.mutt
    else
        echo "Skipping..."
    fi

    chmod 0700 ~/.mutt

    echo "Creating Cache directory."
    if [ ! -d ~/.mutt/cache ] ; then
        mkdir ~/.mutt/cache
    fi

    read -p "What is your name? [$(whoami)]:  " realname

    if [ ${#realname} -lt 2 ] ; then
        realname=$(whoami)
    fi

    read -p "What is your Google email? [$(whoami)@gmail.com]:  " googlemail

    if [ ${#googlemail} -lt 2 ] ; then
        googlemail="$(whoami)@gmail.com"
    fi

    while [ ${NOVALIDPASS} -lt 1 ] ; do
        echo ""

        stty -echo
        read -p "What is your Password:  " gpassa

        echo ""
        read -p "Repeat:  " gpassb

        if [ ${#gpassa} -gt 2 ] ; then
            if [ "${gpassa}" == "${gpassb}" ] ; then
                stty ${TTYORIG}
                mailpass="${gpassa}"
                gpassa=""
                gpassb=""
                NOVALIDPASS=1
            else
                echo "Passwords do not match!"
            fi
        else
            echo "Invalid Password!"
        fi
    done

    smtp_url="smtp:\/\/${googlemail}@smtp.gmail.com:587"

    sed -i "s/set realname =$/set realname = '${realname}'/" ~/.muttrc
    sed -i "s/set from =$/set from = '${googlemail}'/" ~/.muttrc
    sed -i "s/set imap_user =$/set imap_user = '${googlemail}'/" ~/.muttrc
    sed -i "s/set imap_pass =$/set imap_pass = '${mailpass}'/" ~/.muttrc
    sed -i "s/set smtp_url =$/set smtp_url = '${smtp_url}'/" ~/.muttrc
    sed -i "s/set smtp_pass = $/set smtp_pass = '${mailpass}'/" ~/.muttrc

    mailpass=""

    echo ""
    echo "Writing to muttrc..."
    echo "Protecting muttrc..."
    chmod 0600 ~/.muttrc
    echo ""

fi

if ${ISBASHCONF} ; then
    if [ -f "custom/ps1/${SHORT_HOSTNAME}.bash_prompt" ] ; then
        echo ""
        echo "Custom bash prompt for ${LONG_HOSTNAME} found..."
        echo -n "Copying custom/ps1/${SHORT_HOSTNAME}.bash_prompt "
        echo "to ${HOME}/.bash_prompt"
        cp "custom/ps1/${SHORT_HOSTNAME}.bash_prompt" "${HOME}/.bash_prompt"
    fi

    if [ -f "custom/quirks/${SHORT_HOSTNAME}.quirk" ] ; then
        echo ""
        echo "Custom quirks for ${LONG_HOSTNAME} found..."
        echo -n "Copying custom/quirks/${SHORT_HOSTNAME}.quirk "
        echo "to ${HOME}/.quirk"
        cp "custom/quirks/${SHORT_HOSTNAME}.quirk" "${HOME}/.quirk"
    fi
fi

echo ""
echo "Done"
