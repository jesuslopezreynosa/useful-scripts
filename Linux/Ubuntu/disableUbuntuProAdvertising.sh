#!/bin/bash

# 9 April 2026 - From this response on AskUbuntu.com (https://askubuntu.com/a/1434762)

sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak
sudo touch /etc/apt/apt.conf.d/20apt-esm-hook.conf