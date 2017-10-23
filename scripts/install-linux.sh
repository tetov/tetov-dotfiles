#!/usr/bin/env bash

# Env

# TODO: Change to test if commands used are available instead
source ~/tetov-dotfiles/scripts/support-functions.sh

scriptUser=$(whoami)


# Functions

aptInstall () {
    # TODO: Make platform agnostic

    test -z $pkgCommand || _selectPKGRepo

    case $pkgCommand in
        "apt-get")
            sudo apt-get update
            xargs sudo apt-get -y install <"$HOME"/tetov-dotfiles/Aptfile ;;
        "*")
            echo "Script not configured for " $pkgCommand
            return 1
    esac
}

fzfInstall () {
    test -z $pkgCommand || _selectPKGRepo

    case $pkgCommand in
        "pacman") sudo pacman -Ss fzf ;;
        "brew") brew install fzf ;;
        "apt-get")
            checkDep git || return 1
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install ;;
        *) echo "Something went wrong." ;;
    esac

}

setZshShell () {
    _checkDep zsh || return 1

    # TODO: Test if following works on mac (try contain instead?)
    if [[ $SHELL =~ "zsh" ]]; then
        echo "ZSH is already set as " $scriptUser "'s shell'"
    else
        if [[ $UNAME == "darwin" ]]; then
            sudo chsh --shell="$(which zsh)" "$scriptUser"
        else
            sudo chsh --shell=/bin/zsh "$scriptUser"
        fi
    fi
}

cloneDotfilesRepo () {
    _checkDep git || { echo "Git not installed." ; return 1 ; }

    git clone https://github.com/tetov/tetov-dotfiles.git ~/tetov-dotfiles \
        || { echo "Git clone failed. Exiting." ; return 1 ; }
    }

    # INTERACTION

_promptUser 'Set zsh as login shell?' && setZshShell
_promptUser 'Do you want to install fzf?' && fzfInstall
_promptUser 'Do you want to install apt packages?' && aptInstall
_promptUser 'Do you want to run the stow script?' && ~/tetov-dotfiles/stow.sh
_promptUser 'Do you want to run the antigen & vundle script?' && ~/tetov-dotfiles/install-common.sh