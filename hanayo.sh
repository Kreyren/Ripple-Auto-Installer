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
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=${PATH}:${GOPATH}/bin' >> ~/.bashrc
source ~/.bashrc

# Cloning Hanayo (from zxq.co), github?;old
sudo go get -u zxq.co/ripple/hanayo
cd go/src/zxq.co/ripple/hanayo
sudo go build .

# Make Sure to press "enter" and type "I agree" (hanayo licence agreement)
./hanayo
clear
./hanayo
echo "Done! You Can Now view your site in localhost:45221"
