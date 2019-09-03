#!/usr/bin/env bash
# Created by github.com/kreyren under the terms of GPL-2 (https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

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
###X cheesegull (https://zxq.co/ripple/cheesegull) -> Removed based on uniminin
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

configure_lets() {
	# Fetch
	[ ! -e "${srcdir}/lets" ] && (git clone 'https://zxq.co/ripple/lets.git' "${srcdir}/lets" || die 1 "Unable to fetch ripple/lets") || edebug "Directory $srcdir/lets alredy exists"

	# TODO: Sanitization on required deps
	# TODO: pip can also be used
  if ! command -v "pip3" >/dev/null; then die 1 "Command 'pip3' is not executable" ; fi

	git clone 'https://zxq.co/ripple/ripple-python-common.git' "${srcdir}/lets/common" || die 1 "Unable to clone ripple-python-common.git"
	git clone 'https://github.com/osufx/secret' "${srcdir}/lets/secret" || die 1 "Unable to clone lets-secret"
	git clone 'https://github.com/Francesco149/oppai-ng.git' "${srcdir}/lets/pp/oppai-ng" || die 1 "Unable to clone oppai-ng"
	# No access rights
	## git clone 'git@zxq.co:ripple/maniapp-osu-tools.git' "${srcdir}/lets/calc-no-replay" || die 1 "Unable to clone maniapp-osu-tools"
	git clone 'https://zxq.co/ripple/catch-the-pp.git' "${srcdir}/lets/pp/catch_the_pp" || die 1 "Unable to clone cat-the-pp"

	[ -e "${srcdir}/lets/requirements.txt" ] && (pip3 install -r "${srcdir}/lets/requirements.txt" && edebug "pip3 returned true for $srcdir/lets/requirements.txt" || die "pip3 failed to fetch required packages") || die 1 "File ${srcdir}/lets/requirements.txt doesn't exists"

	die 0
}

configure_hanayo() {
	if ! command -v "go" >/dev/null; then die 1 "Command 'go' is not executable" ; fi
	# KREYRENIZE: golang-go on debian
	# Fetch
	[ ! -e "${GOPATH}/src/zxq.co/ripple/hanayo" ] && (go get -u 'zxq.co/ripple/hanayo' || die 1 "Unable to get hanayo using go") || einfo "hanayo is already fetched"

	[ ! -e "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo" ] && (go build -o "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo" "${GOPATH}/src/zxq.co/ripple/hanayo/" || die 1 "Unable to build hanayo in ${GOPATH}/src/zxq.co/ripple/hanayo/hanayo") || einfo "Hanayo is already compiled"

	die 0
}

configure_rippleapi() {
	if ! command -v "go" >/dev/null; then die 1 "Command 'go' is not executable" ; fi
	# KREYRENIZE: golang-go on debian
	# Fetch
	[ ! -e "${GOPATH}/src/zxq.co/ripple/rippleapi" ] && (go get -u 'zxq.co/ripple/rippleapi' || die 1 "Unable to get rippleapi using go") || einfo "rippleapi is already fetched"

	[ ! -e "${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi" ] && (go build -o "${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi" "${GOPATH}/src/zxq.co/ripple/rippleapi/" || die 1 "Unable to build rippleapi in ${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi") || einfo "rippleapi is already compiled"

	die 0
}

configure_avatarservergo() {
	# fetch
	[ -e "${srcdir}/avatar-server-go" ] && (git clone 'https://zxq.co/Sunpy/avatar-server-go.git' "${srcdir}/avatar-server-go" || die 1 "Unable to fetch Sunpy/avatar-server-go") || edebug "Directory $srcdir/lets alredy exists"

	die 0
}

configure_pep_py() {
	# Fetch
	[ ! -e "${srcdir}/pep.py" ] && (git clone 'https://zxq.co/ripple/pep.py.git' "${srcdir}/pep.py" || die 1 "Unable to fetch Sunpy/pep.py") || edebug "Directory $srcdir/lets alredy exists"

	# Configure
	## TODO: doesn't switch directory correctly
	git submodule init "${srcdir}/pep.py/" || die 1 "Unable to init submodules in $srcdir/pep.py"
	git submodule update "${srcdir}/pep.py/" || die 1 "Unable to update submodules in $srcdir/pep.py"

	[ -e "${srcdir}/pep.py/requirements.txt" ] && (pip3 install -r "${srcdir}/pep.py/requirements.txt" && edebug "pip3 returned true for $srcdir/lets/requirements.txt" || die "pip3 failed to fetch required packages") || die 1 "File ${srcdir}/pep.py/requirements.txt does not exists"

	die 0
}

configure_nginx() {
	die 0
}

# LOGIC

checkroot "$@" && while [[ "$#" -ge '0' ]]; do case "$1" in
	-C|--directory)
		[[ "$2" != -* ]] && die 2 "Argument --directory doesn't expect two variables"
		[ -z "$1" ] && die 2 "Argument --directory expects one value pointing to directory used"
		[ ! -d "$1" ] && die 2 "Argument --directory doesn't recognize '$1' as valid directory"
		export directory="$1" ;	shift 2
	;;
	--srcdir)
		[[ "$2" != -* ]] && die 2 "Argument --srcdir doesn't expect two variables"
		[ -z "$1" ] && die 2 "Argument --srcdir expects one value pointing to directory used for source files"
		[ ! -d "$1" ] && die 2 "Argument --srcdir doesn't recognize '$1' as valid directory"
		export srcdir="$1" ; shift 2
	;;
	-h|-\?|--help) printf "STUB: HELP_PAGE" && break ;; # TODO: Sanitize on variables
	-d|--debug) export debug="true" ; shift 1 ;; # TODO: Sanitize on variables
	--test) # STUB
		[ -z "$directory" ] && export directory=""
		[ -z "$srcdir" ] && export srcdir="/usr/src/"
		export GOPATH="${srcdir}/go"
		configure_rippleapi
		#configure_lets
		#configure_avatarservergo
		#configure_pep_py
		#configure_hanayo
	;;
	--uniminin)
		[ -z "$directory" ] && export directory=""
		[ -z "$srcdir" ] && export srcdir="$(pwd)"
		configure_lets
	;;
	"") die 1 "Not Finished" ;;
	*) die 2 "Argument '$1' is not recognized by ${FUNCNAME[0]}"; break
esac; done
