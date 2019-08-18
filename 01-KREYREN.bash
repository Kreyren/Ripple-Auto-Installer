#!/usr/bin/env bash

# ABSTRACT
## fetch deps
### Python 3.5.1 / expecting 3.6
### PHP (5.6.4 tested)
### MySQL (5.6.18 tested)
#### mariadb
#### local database
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

# GLOBAL

# Sanitization for API used
# [ -e "/tmp/00-ripple-api.bash" ] && (source "/tmp/00-ripple-api.bash" || die 1 "Unable to fetch ripple API") || warn "Unable to source ripple-api, trying to fetch" && (wget "https://raw.githubusercontent.com/Kreyren/Ripple-Auto-Installer/kreyrenizing/00-ripple-api.bash" -O "/tmp/00-ripple-api.bash" || die 1 "Unable to fetch ripple-api") && (source "/tmp/00-ripple-api.bash" && einfo "ripple-api was fetched and sourced" || die 1 "Failed to source ripple-api")

# Error handling
if ! command -v einfo > /dev/null; then	einfo()	{	printf "INFO: %s\n" "$1"	1>&2	;	} fi
if ! command -v warn > /dev/null; then	warn()	{	printf "WARN: %s\n" "$1"	1>&2	;	} fi
if [ -n "$debug" ]; then
	edebug()	{	printf "DEBUG: %s\n" "$1"	1>&2	; }
else edebug() { true ; }
fi
if ! command -v die > /dev/null; then	die()	{
	case $1 in
		0)	true && ([ -n "$debug" ] && edebug "Script returned true") ;; # TRUE
		1)	false	;; # FALSE
		# Syntax err
		2)	([ -n "$2" ] && printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1") || (printf "FATAL: Syntax error $0 $1 $2 $3 in ${FUNCNAME[0]}\n" 1>&2 ; exit "$1") ;;
		# Permission issue
		3)	([ -n "$2" ] && printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1") || (printf "FATAL: Unable to elevate root access from $([ -n "$EUID" ] && printf "EUID ($EUID)")\n"	1>&2	;	exit "$1")	;;
		# Custom
    wtf) printf "FATAL: Unexpected result in ${FUNCNAME[0]}" ;;
    kreyren) printf "Killed by kreyren" ;;
		*)	printf "FATAL: %s\n" "$2" 1>&2 ; exit "$1" ;;
	esac
} fi

# FUNCTIONS

checkroot() { # Check if executed as root, if not tries to use sudo if KREYREN variable is not blank
  # Licenced by github.com/kreyren under GPL-2
	if [[ "$EUID" == 0 ]]; then
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
# Fetch repositories
[ ! -e "/usr/src/lets" ] && (git clone https://zxq.co/ripple/lets.git /usr/src/lets || die 1 "Unable to fetch ripple/lets") || edebug "Directory /usr/src/lets alredy exists"
[ ! -e "/usr/src/hanayo" ] && (git clone https://zxq.co/ripple/hanayo.git /usr/src/hanayo || die 1 "Unable to fetch ripple/hanayo") || edebug "Directory /usr/src/hanayo alredy exists"
[ ! -e "/usr/src/rippleapi" ] && (git clone https://zxq.co/ripple/rippleapi.git /usr/src/rippleapi || die 1 "Unable to fetch ripple/rippleapi") || edebug "Directory /usr/src/rippleapi alredy exists"
[ ! -e "/usr/src/chesegull" ] && (git clone https://zxq.co/ripple/cheesegull.git /usr/src/chesegull || die 1 "Unable to fetch ripple/chesegull") || edebug "Directory /usr/src/chesegull alredy exists"
[ ! -e "/usr/src/avatar-server-go" ] && (git clone https://zxq.co/Sunpy/avatar-server-go.git /usr/src/avatar-server-go || die 1 "Unable to fetch Sunpy/avatar-server-go") || edebug "Directory /usr/src/lets alredy exists"
}

# LOGIC

checkroot "$@" && while [[ "$#" -gt 0 ]]; do case "$1" in
  --action)
    if [[ "$2" != -* ]] && [[ "$3" != -* ]]; then
			action "$2" "$3"
			shift 3
		elif [[ "$2" != -* ]] && [[ "$3" == -* ]]; then
			action "$1"
			shift 1
		elif [[ "$2" == -* ]] && [[ "$3" == -* ]]; then
      action
			shift 1
		else die "Unexpected result in -action logic"
		fi
  ;;
	-d|--debug) debug="true" ; shift ;;
	-h|--help) printf "STUB: HELP_PAGE" ;;
	"") action ; die 0 ;; # Needed to output success
	*) die 2 ; break
esac; done
