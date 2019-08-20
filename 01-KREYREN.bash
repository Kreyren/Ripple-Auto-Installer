#!/usr/bin/env bash

# ABSTRACT
## fetch deps
### Python 3.5.1 / expecting 3.6
### PHP (5.6.4 tested)
### MySQL (5.6.18 tested)
#### local database
#### sqlite
#### mariadb
### pep.py
### lets
### avatar-server
### rippleapi
### hanayo
### nginx (1.9.11 tested)
#### Alternatively Apache
### orders?
## Fetch repositories
###X lets (https://zxq.co/ripple/lets)
###X hanayo (https://zxq.co/ripple/hanayo)
###X rippleapi (https://zxq.co/ripple/rippleapi)
###X cheesegull (https://zxq.co/ripple/cheesegull)
###X avatarserver (https://zxq.co/Sunpy/avatar-server-go)
###X pyp.pi (https://zxq.co/ripple/pep.py)
## Configure everything (mysql pep.py lets avatar-server rippleapi hanayo nginx)
### mysql
#### Fetch package
##### Debian: mysql-server / default-mysql-server / default-mysql-server-core (preffered?)
### pep.py
#### Deprecated 29 june 2019
### LETS
#### git submodule init && git submodule update -> https://gist.github.com/Kreyren/27bf5a6cf1aacba3d7b3fabdb8555c8b
#### pip install -r requirements.txt
##### pip reguired (DEBIAN: python3-pip)

# GLOBAL

# Sanitization for API used
# [ -e "/tmp/00-ripple-api.bash" ] && (source "/tmp/00-ripple-api.bash" || die 1 "Unable to fetch ripple API") || warn "Unable to source ripple-api, trying to fetch" && (wget "https://raw.githubusercontent.com/Kreyren/Ripple-Auto-Installer/kreyrenizing/00-ripple-api.bash" -O "/tmp/00-ripple-api.bash" || die 1 "Unable to fetch ripple-api") && (source "/tmp/00-ripple-api.bash" && einfo "ripple-api was fetched and sourced" || die 1 "Failed to source ripple-api")

# Variables
maintainer="github.com/kreyren/Ripple-Auto-Installer"

# Error handling
if ! command -v "einfo" > /dev/null; then	einfo()	{	printf "INFO: %s\n" "$1"	1>&2	;	} fi
if ! command -v "warn" > /dev/null; then	warn()	{	printf "WARN: %s\n" "$1"	1>&2	;	} fi
if [ -n "$debug" ]; then
	edebug()	{	printf "DEBUG: %s\n" "$1"	1>&2	; }
else edebug() { true ; }
fi
if ! command -v "die" > /dev/null; then	die()	{
	case $1 in
		0|true)	([ -n "$debug" ] && edebug "Script returned true") ; exit "$1" ;;
		1|false) # False
			if [ -n "$2" ]; then printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1"
			elif [ -z "$2" ] ; then printf "FATAL: Script returned false $([ -n "$EUID" ] && printf "from EUID ($EUID)") ${FUNCNAME[0]}\n" 1>&2 ; exit "$1"
			else die wtf
			fi
		;;
		2) # Syntax err
			if [ -n "$2" ]; then printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1"
			elif [ -z "$2" ]; then printf "FATAL: Syntax error $([ -n "$debug" ] && printf "$0 $1 $2 $3 in ${FUNCNAME[0]}")\n" 1>&2 ; exit "$1"
			else die wtf
			fi
		;;
		3) # Permission issue
		if [ -n "$2" ]; then printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1"
		elif [ -z "$2" ]; then printf "FATAL: Unable to elevate root access from $([ -n "$EUID" ] && printf "EUID ($EUID)")\n" 1>&2	;	exit "$1"
		else die wtf
		fi
		;;
		# Custom
    wtf) printf "FATAL: Unexpected result in ${FUNCNAME[0]}\n" ;;
    kreyren) printf "Killed by kreyren\n" ;;
		*)	printf "FATAL: %s\n" "$2" 1>&2 ; exit 1 ;;
	esac }
fi

# FUNCTIONS

checkroot() { # Check if executed as root, if not tries to use sudo if KREYREN variable is not blank
  # Licenced by github.com/kreyren under GPL-2
	if [[ "$EUID" == '0' ]]; then
		return
	elif [[ -x "$(command -v "sudo")" ]] && [ -n "$KREYREN" ]; then
			einfo "Failed to aquire root permission, trying reinvoking with 'sudo' prefix"
			sudo "$0" "$@" && edebug "Script has been executed with 'sudo' prefix" || die 3
			die 0
	elif [[ ! -x "$(command -v "sudo")" ]] && [ -n "$KREYREN" ]; then
		einfo "Failed to aquire root permission, trying reinvoking as root user."
		exec su -c "$0 $*" && edebug "Script has been executed with 'su' prefix" || die 3
		die 0
	else
		die 3
	fi
}

action() {
	warn "THIS SCRIPT IS WORK IN PROGRESS!!\nif script ends with fatal report issue to $maintainer/issues and wait for commit."

  # Fetch repositories
  [ ! -e "/usr/src/lets" ] && (git clone https://zxq.co/ripple/lets.git /usr/src/lets || die 1 "Unable to fetch ripple/lets") || edebug "Directory /usr/src/lets alredy exists"
  [ ! -e "/usr/src/hanayo" ] && (git clone https://zxq.co/ripple/hanayo.git /usr/src/hanayo || die 1 "Unable to fetch ripple/hanayo") || edebug "Directory /usr/src/hanayo alredy exists"
  [ ! -e "/usr/src/rippleapi" ] && (git clone https://zxq.co/ripple/rippleapi.git /usr/src/rippleapi || die 1 "Unable to fetch ripple/rippleapi") || edebug "Directory /usr/src/rippleapi alredy exists"
  [ ! -e "/usr/src/avatar-server-go" ] && (git clone https://zxq.co/Sunpy/avatar-server-go.git /usr/src/avatar-server-go || die 1 "Unable to fetch Sunpy/avatar-server-go") || edebug "Directory /usr/src/lets alredy exists"
  [ ! -e "/usr/src/pep.py" ] && (git clone https://zxq.co/ripple/pep.py.git /usr/src/pep.py || die 1 "Unable to fetch Sunpy/pep.py") || edebug "Directory /usr/src/lets alredy exists"

  # Required for lets
  if ! command -v mysql_config >/dev/null; then die 1 "Command 'mysql_config' is not executable\n"
	#TODO: elif grep -qF "Debian" "/etc/os-release" && [ -n "$KREYREN" ]; then	einfo "This package depends on mysql_config from libmariadb-dev-compat on Debian which will be installed now" ; apt install libmariadb-dev-compat -y
	fi

  pip3 install -r /usr/src/lets/requirements.txt && edebug "pip3 returned true for /usr/src/lets/requirements.txt" || die "pip3 failed to fetch required packages"
}

# LOGIC

checkroot "$@" && while [[ "$#" -ge 0 ]]; do case "$1" in
	-h|-\?|--help) printf "STUB: HELP_PAGE" && break ;; # TODO: Sanitize on variables
	-d|--debug) export debug="true" ; shift 1 ;; # TODO: Sanitize on variables
	"") action ;;
	*) die 2 ; break
esac; done
