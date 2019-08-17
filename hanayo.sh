#!/usr/bin/env bash

# HELPER: sudo wrapper
my_sudo() { [ -x $(command -v "sudo") ] && printf "${EUID:+sudo }" ; }

# HELPER: Die
if ! command -v "die" > /dev/null; then	die()	{
  	case $1 in
    8)	printf "FATAL: This distribution is not supported by this script %s\n" 1>&2 ; exit $1 ;;
		# Custom
		*)	(printf "FATAL: Syntax error $([ -n "${FUNCNAME[0]}" ] && printf "in ${FUNCNAME[0]}")\n%s\n" "$2"	1>&2	;	exit "$1") || (printf "FATAL: %s\n" "$1" 1>&2 ; exit $1)
	esac
} fi

declare hanayo_port

askPrerequisites() {
  valid_domain=0

  #Ask user for port to use for frontend
  printf "\n\n..:: FRONTEND ::.."
  printf "\nPort [6969]: "
  read hanayo_port
  hanayo_port=${hanayo_port:=6969}
}


setup-hanayo() {
# Updating Is Necessary (at first)
if [ -x $(command -v "apt") ]; then
  # Update repositories
  my_sudo apt {update,upgrade,dist-upgrade,install git} -y
  # Update ubuntu and install deps
  if grep -q 'Ubuntu' /etc/os-release; then my_sudo add-apt-repository ppa:longsleep/golang-backports -y && my_sudo apt install golang-go -y ; else die 8 ; fi
fi

# Setting GO Path
# STUB: Should be handled using wrapper, scripts should never touch ~/.bashrc
if ! grep -q "export GOPATH="$HOME/go"" "$HOME/.bashrc"; then printf "export GOPATH="%s/go"" "$HOME" >> "$HOME/.bashrc" ; fi

if ! grep -q "export PATH="${PATH}:${GOPATH}/bin"" "$HOME/.bashrc"; then printf "export PATH="%s:%s/bin"" "${PATH}" "${GOPATH}" >> "$HOME/.bashrc" ; fi

source "$HOME/.bashrc"

  echo "Setting up Hanayo..."

  my_sudo go get -u zxq.co/ripple/hanayo
  cd go/src/zxq.co/ripple/hanayo
  my_sudo go build .
  exec hanayo

  sed -i 's#ListenTo=#ListenTo=127.0.0.1:'$hanayo_port'#g; hanayo.conf
  exec hanayo && echo "Hanayo is running at localhost:"$hanayo_port
