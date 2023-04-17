#!/bin/sh

echo "┌──────────┐"
echo "│  User    │" $(echo $USER)@$(cat /etc/hostname)
echo "│  DE/WM   │" $(echo $XDG_CURRENT_DESKTOP)
echo "├──────────┤"
echo "│  System  │" $(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
echo "│  Kernel  │" $(uname -r)
echo "│  Shell   │" $(echo $SHELL | sed 's/.*\///')
echo "│  Uptime  │" $(uptime | awk '{print $3,$4}' | sed 's/,//')
echo "├──────────┤"
echo "│  CPU     │" $(lscpu | grep 'Model name' | cut -d ':' -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
echo "│  GPU     │" $(lspci | grep VGA | cut -d ':' -f 3 | awk '{$1=$1};1' | sed 's/.*\[\(.*\)\].*/\1/')
echo "│  RAM     │" $(free -h | grep "Mem:" | awk '{print $3}')/$(free -h | grep "Mem:" | awk '{print $2}')
echo "├──────────┤"
echo "│  Colors  │" $(tput setaf 1)■$(tput sgr0)$(tput setaf 3)■$(tput sgr0)$(tput setaf 2)■$(tput sgr0)$(tput setaf 6)■$(tput sgr0)$(tput setaf 4)■$(tput sgr0)$(tput setaf 5)■$(tput sgr0)$(tput setaf 7)■$(tput sgr0)$(tput setaf 0)■$(tput sgr0)
echo "└──────────┘"