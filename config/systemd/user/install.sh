#!/bin/bash

# Declare constants

INSTALL_PATH="${HOME}/.config/systemd/user"
TIMER_FILE="btrfs-sync.timer"
SERVICE_FILE="btrfs-sync.service"

# Create unit files if missing

if [ ! -f "$TIMER_FILE" ]; then

    cp "./${TIMER_FILE}"* "./${TIMER_FILE}"

fi

if [ ! -f "$SERVICE_FILE" ]; then

    cp "./${SERVICE_FILE}"* "./${SERVICE_FILE}"

fi

# Link the timer file

target="$(readlink -f "./${TIMER_FILE}")"
link_name="${INSTALL_PATH}/${TIMER_FILE}"

ln -s "$target" "$link_name"

# Link the service file

target="$(readlink -f "./${SERVICE_FILE}")"
link_name="${INSTALL_PATH}/${SERVICE_FILE}"

ln -s "$target" "$link_name"
