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

action2() {
# Sanitization for API used
[ ! -e "/etc/bash" ] && (mkdir "/etc/bash" || die 1 "Unable to make a new directory in /etc/bash") || edebug "Directory /etc/bash already exists"

[ -e "/etc/bash/00-ripple-api.bash" ] && (source "/etc/bash/00-ripple-api.bash" || die 1 "Unable to fetch ripple API") || warn "Unable to source ripple-api, trying to fetch" && (wget "https://raw.githubusercontent.com/Kreyren/Ripple-Auto-Installer/kreyrenizing/00-ripple-api.bash" -O "/etc/bash/00-ripple-api.bash" || die 1 "Unable to fetch ripple-api") && (source "/etc/bash/00-ripple-api.bash" && einfo "ripple-api was fetched and sourced" || die 1 "Failed to source ripple-api")
}

action() {
# Fetch repositories
[ ! -e "/usr/src/lets" ] && (git clone https://zxq.co/ripple/lets.git || die 1 "Unable to fetch ripple/lets") || edebug "Directory /usr/src/lets alredy exists"
[ ! -e "/usr/src/hanayo" ] && (git clone https://zxq.co/ripple/hanayo.git || die 1 "Unable to fetch ripple/hanayo") || edebug "Directory /usr/src/hanayo alredy exists"
[ ! -e "/usr/src/rippleapi" ] && (git clone https://zxq.co/ripple/rippleapi.git || die 1 "Unable to fetch ripple/rippleapi") || edebug "Directory /usr/src/rippleapi alredy exists"
[ ! -e "/usr/src/chesegull" ] && (git clone https://zxq.co/ripple/chesegull.git || die 1 "Unable to fetch ripple/chesegull") || edebug "Directory /usr/src/chesegull alredy exists"
[ ! -e "/usr/src/avatar-server-go" ] && (git clone https://zxq.co/Sunpy/avatar-server-go.git || die 1 "Unable to fetch Sunpy/avatar-server-go") || edebug "Directory /usr/src/lets alredy exists"
}


checkroot "$@" && while [[ "$#" -gt 0 ]]; do case "$1" in
	# TODO: Capture $1 and $2 for MFH
	-mfh|--make-file-hierarchy|-MFH)
		if [[ "$2" != -* ]] && [[ "$3" != -* ]]; then
			MFH "$2" "$3"
			shift 3
		elif [[ "$2" != -* ]] && [[ "$3" == -* ]]; then
			MFH "$1"
			shift 1
		elif [[ "$2" == -* ]] && [[ "$3" == -* ]]; then
			shift 1
		else die "Unexpected result in -mfh logic"
		fi
	;;
  -action) action1 ; action ;;
	-d|--debug) debug="true" ; shift ;;
	-h|--help) printf "STUB: HELP_PAGE" ;;
	"") die 0 ;; # Needed to output success
	*) die 2 ; break
esac; done
