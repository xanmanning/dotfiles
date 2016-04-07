#!/bin/bash

echo "Installing Config Files..."

for CONFIG in _* ; do
	echo "Copying ${CONFIG} to ${HOME}/.${CONFIG:1}"
	cp "${CONFIG}" "${HOME}/.${CONFIG:1}"
done

echo ""
echo "Done"
