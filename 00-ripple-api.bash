#!/usr/bin/env bash
# Ripple api written in bash
# Created by github.com/kreyren under the terms of GPL-2 (https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

# CHECKROOT
checkroot() { # Check if executed as root, if not tries to use sudo if KREYREN variable is not blank
  # Licenced by github.com/kreyren under GPL-2
	if [[ "$EUID" == 0 ]]; then
		return
	elif [[ -x "$(command -v "sudo")" ]] && [ -n "$KREYREN" ]; then
			einfo "Failed to aquire root permission, trying reinvoking with 'sudo' prefix"
			exec sudo "$0" "$@" || die 3
			die 0
	elif [[ ! -x "$(command -v "sudo")" ]] && [ -n "$KREYREN" ]; then
		einfo "Failed to aquire root permission, trying reinvoking as root user."
		exec su -c "$0 $*" || die 3
		die 0
	else
		die 3
	fi
}

# Error handling
if ! command -v "einfo" > /dev/null; then einfo() { printf "INFO: %s\n" "${*}" 1>&2 ; } ; fi
if ! command -v "warn" > /dev/null; then warn() { printf "WARN: %s\n" "${*}" 1>&2 ; } ; fi
if ! command -v "edebug" > /dev/null; then edebug() { printf "DEBUG: %s\n" "${*}" 1>&2 ; } ; fi
die() { printf "FATAL: ${*}\n" 1>&2 ; exit 1 ; }
if ! command -v "die" > /dev/null; then	die()	{
  	case $1 in
    8)	printf "FATAL: This distribution is not supported by this script %s\n" 1>&2 ; exit $1 ;;
		# Custom
    wtf) printf "FATAL: Unexpected result in ${FUNCNAME[0]}" ;;
		*)	(printf "FATAL: Syntax error $([ -n "${FUNCNAME[0]}" ] && printf "in ${FUNCNAME[0]}")\n%s\n" "$2"	1>&2	;	exit "$1") || (printf "FATAL: %s\n" "$1" 1>&2 ; exit $1)
	esac
} fi
