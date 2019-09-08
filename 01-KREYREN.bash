#!/usr/bin/env bash
# Created by github.com/kreyren under the terms of GPL-2 (https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

# GLOBAL

## KREYPI - INIT
if ! command -v 'wget' >/dev/null && [ ! -e "/lib/bash/kreypi.bash" ]; then printf "FATAL: This script requires 'wget' to be executable for downloading of kreypi (https://github.com/RXT067/Scripts/tree/kreyren/kreypi) for further sourcing" ; exit 1 ; fi

[ ! -e "/lib/bash" ] && (mkdir -p "/lib/bash" || printf "ERROR: Unable to make a new directory in /lib/bash" ; exit 1) || $([ -n "$debug" ] && printf "DEBUG: Created a new directory in '/lib/bash'")

[ ! -e "/lib/bash/kreypi.bash" ] && (wget 'https://raw.githubusercontent.com/RXT067/Scripts/kreyren/kreypi/kreypi.bash' -O '/lib/bash/kreypi.bash') ||  $([ -n "$debug" ] && printf "DEBUG: File '/lib/bash/kreypi.bash' already exists")

if [ -e "/lib/bash/kreypi.bash" ]; then
	source "/lib/bash/kreypi.bash" && $([ -n "$debug" ] && printf "DEBUG: Kreypi in '/lib/bash/kreypi.bash' has been successfully sourced") || printf "FATAL: Unable to source '/lib/bash/kreypi.bash'" ; exit 1
elif [ -e "/lib/bash/kreypi.bash" ]; then
	printf "FATAL: Unable to source '/lib/bash/kreypi.bash' since path doesn't exists"
fi

# VARIABLES
export maintainer="github.com/kreyren/Ripple-Auto-Installer"
export GOPATH="${srcdir}/go"

configure_lets() {
	# Fetch
	egit-clone 'https://zxq.co/ripple/lets.git' "${srcdir}/lets"

	# TODO: Sanitization on required deps
	# TODO: pip can also be used
  if ! command -v "pip3" >/dev/null; then die 1 "Command 'pip3' is not executable" ; fi

	[ ! -e "${srcdir}/lets/common" ] && (git clone 'https://zxq.co/ripple/ripple-python-common.git' "${srcdir}/lets/common" || die 1 "Unable to clone ripple-python-common.git")
	[ ! -e "${srcdir}/lets/secret" ] && (git clone 'https://github.com/osufx/secret' "${srcdir}/lets/secret" || die 1 "Unable to clone lets-secret")
	[ ! -e "${srcdir}/lets/pp/oppai-ng" ] && (git clone 'https://github.com/Francesco149/oppai-ng.git' "${srcdir}/lets/pp/oppai-ng" || die 1 "Unable to clone oppai-ng")
	# No access rights
	## git clone 'git@zxq.co:ripple/maniapp-osu-tools.git' "${srcdir}/lets/calc-no-replay" || die 1 "Unable to clone maniapp-osu-tools"
	[ ! -e "${srcdir}/lets/pp/catch_the_pp" ] && (git clone 'https://zxq.co/ripple/catch-the-pp.git' "${srcdir}/lets/pp/catch_the_pp" || die 1 "Unable to clone cat-the-pp")

	[ -e "${srcdir}/lets/requirements.txt" ] && (pip3 install -r "${srcdir}/lets/requirements.txt" && edebug "pip3 returned true for $srcdir/lets/requirements.txt" || die "pip3 failed to fetch required packages") || die 1 "File ${srcdir}/lets/requirements.txt doesn't exists"

	# Compile
	if [ ! -e "${srcdir}/lets/build/" ]; then (cd "${srcdir}/lets" && python3 "${srcdir}/lets/setup.py" build_ext --inplace  || die 1 "python failed for lets")
elif [ -e "${srcdir}/lets/build/" ]; then einfo "lets is already compiled"
	fi

	die 0
}

configure_hanayo() {
	# KREYRENIZE: golang-go on debian
	if ! command -v "go" >/dev/null; then die 1 "Command 'go' is not executable" ; fi

	# Fetch
	if [ ! -e "${GOPATH}/src/zxq.co/ripple/hanayo" ]; then  go get -u 'zxq.co/ripple/hanayo' || die 1 "Unable to get hanayo using go"
	elif [ -e "${GOPATH}/src/zxq.co/ripple/hanayo" ]; then einfo "hanayo is already fetched"
	fi

	if [ ! -e "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo" ]; then go build -o "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo" "${GOPATH}/src/zxq.co/ripple/hanayo/" || die 1 "Unable to build hanayo in ${GOPATH}/src/zxq.co/ripple/hanayo/hanayo"
	elif [ -e "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo" ]; then einfo "Hanayo is already compiled"
	fi

	# Config
	# TODO: Fetch IP from resolv.conf
	[ ! -e "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo.conf" ] && printf '%s/n' \
		'; ip:port from which to take requests.' \
		"ListenTo=':45221'" \
		'; Whether ListenTo is an unix socket.' \
		[ "$(uname)" = "Linux" ] && printf '%s' "\'Unix=true\'" || printf '%s' "\'Unix=false\'"  \
		'; MySQL server DSN' \
		'DSN='1.1.1.1'' \
		'RedisEnable='false'' \
		'AvatarURL='https://a.ripple.moe'' \
		'BaseURL='https://ripple.moe'' \
		'API='http://localhost:40001/api/v1/'' \
		'BanchoAPI='https://c.ripple.moe'' \
		'CheesegullAPI='https://storage.ripple.moe/api'' \
		'APISecret='Potato'' \
		'; If this is true, files will be served from the local server instead of the CDN.' \
		'Offline='false'' \
		'; Folder where all the non-go projects are contained, such as old-frontend, lets, ci-system. Used for changelog.' \
		"MainRippleFolder='${srcdir}/Ripple'" \
		'; location folder of avatars, used for placing the avatars from the avatar change page.' \
		'AvatarsFolder=' \
		'CookieSecret=' \
		'RedisMaxConnections='0'' \
		'RedisNetwork=' \
		'RedisAddress=' \
		'RedisPassword=' \
		'DiscordServer='https://discord.gg/sBxy77'' \
		'BaseAPIPublic=' \
		'; This is a fake configuration value. All of the following from now on should only really be set in a production environment.' \
		'Production=0' \
		'MailgunDomain=' \
		'MailgunPrivateAPIKey=' \
		'MailgunPublicAPIKey=' \
		'MailgunFrom='"Ripple" <noreply@ripple.moe>'' \
		'RecaptchaSite=' \
		'RecaptchaPrivate=' \
		'DiscordOAuthID=' \
		'DiscordOAuthSecret=' \
		'DonorBotURL='https://donatebot.io/checkout/481111107394732043'' \
		'DonorBotSecret=' \
		'CoinbaseAPIKey=' \
		'CoinbaseAPISecret=' \
		'SentryDSN=' \
		'IP_API='https://ip.zxq.co'' \
	> "${GOPATH}/src/zxq.co/ripple/hanayo/hanayo.conf"

	warn "Please configure ${GOPATH}/src/zxq.co/ripple/hanayo/hanayo.conf manually"

	die 0

}

configure_rippleapi() {
	# KREYRENIZE: golang-go on debian
	if ! command -v "go" >/dev/null; then die 1 "Command 'go' is not executable" ; fi

	# Fetch
	if [ ! -e "${GOPATH}/src/zxq.co/ripple/rippleapi" ]; then go get -u 'zxq.co/ripple/rippleapi' || die 1 "Unable to get rippleapi using go"
	elif [ -e "${GOPATH}/src/zxq.co/ripple/rippleapi" ]; then einfo "rippleapi is already fetched"
	fi

	if [ ! -e "${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi" ]; then go build -o "${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi" "${GOPATH}/src/zxq.co/ripple/rippleapi/" || die 1 "Unable to build rippleapi in ${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi"
	elif [ -e "${GOPATH}/src/zxq.co/ripple/rippleapi/rippleapi" ]; then einfo "rippleapi is already compiled"
	fi

	die 0
}

configure_avatarservergo() {
	# KREYRENIZE: golang-go on debian
	if ! command -v "go" >/dev/null; then die 1 "Command 'go' is not executable" ; fi

	# Fetch
	if [ ! -e "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go" ]; then go get -u 'zxq.co/Sunpy/avatar-server-go' || die 1 "Unable to get avatar-server-go using go"
	elif [ -e "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go" ]; then einfo "avatar-server-go is already fetched"
	fi

	# Compile
	if [ ! -e "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go/avatar-server-go" ]; then go build -o "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go/avatar-server-go" "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go/" || die 1 "Unable to build avatar-server-go in ${GOPATH}/src/zxq.co/Sunpy/avatar-server-go"
	elif [ -e "${GOPATH}/src/zxq.co/Sunpy/avatar-server-go/avatar-server-go" ]; then einfo "avatar-server-go is already compiled"
	fi

	die 0
}

configure_pep_py() {
	# Fetch - pep.py
	egit-clone 'https://zxq.co/ripple/pep.py.git' "${srcdir}/pep.py"

	# Fetch deps
	egit-clone 'https://zxq.co/ripple/ripple-python-common.git' "${srcdir}/pep.py/common"

	# Fetch deps for python
	if ! command -v "pip3" >/dev/null; then die 1 "Command 'pip3' is not executable" ; fi

	if [ -e "${srcdir}/pep.py/requirements.txt" ]; then (pip3 install -r "${srcdir}/pep.py/requirements.txt" && edebug "pip3 returned true for $srcdir/lets/requirements.txt" || die "pip3 failed to fetch required packages")
	elif [ ! -e "${srcdir}/pep.py/requirements.txt" ]; then die 1 "File ${srcdir}/pep.py/requirements.txt does not exists"
	fi

	# Compile
	if [ ! -e "${srcdir}/pep.py/build/" ]; then (cd "${srcdir}/pep.py" && python3 "${srcdir}/pep.py/setup.py" build_ext --inplace  || die 1 "python failed")
	elif [ -e "${srcdir}/pep.py/build/" ]; then einfo "pep.py is already compiled"
	fi

	# TODO: Sanitization for python required

	die 0
}

configure_nginx() {
	die 1 "nginx configuration is not finished"
}


configure_ruri() {
	# Fetch
	egit-clone 'https://github.com/kreyren/kruri.git' "${srcdir}/ruri"

	# Check for required libs
	[ ! -e "/usr/include/connman" ] && die 1 "Required libraries are not present, please install 'libmysqlcppconn-dev' package or it's alternative"

	# Check for GCC
	if ! command -v "g++-9" >/dev/null; then die 1 "Command 'g++-9' is not executable" ; fi

	# HOTFIX
	(cd "${srcdir}/ruri/ruri" && g++-9 -std=c++17 lz4.c *cpp BCrypt/*c -D LINUX -I pathtosql/mysql/include -pthread -lmysqlcppconn -w -march=native -O2 || die 1 "Failed to compile ruri")

}

configure_sora() {
	# Fetch
	egit-clone 'https://github.com/Mempler/Sora' "${srcdir}/Sora"

	die 1 "Sora configuration is not finished"
}

configure_mysql() {
	if ! command -v "mysql_config" >/dev/null; then die 1 "Command 'myshql_config' is not executable" ; fi

	die 1 "Mysql configuration is not finished"
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
		#configure_rippleapi
		#configure_lets
		#configure_avatarservergo
		#configure_pep_py
		configure_hanayo
		#configure_ruri
		#configure_sorano config.i
		die 0
	;;
	--base) # STUB
		[ -z "$directory" ] && export directory=""
		[ -z "$srcdir" ] && export srcdir="/usr/src/"
		configure_rippleapi
		configure_lets
		configure_avatarservergo
		configure_pep_py
		configure_hanayo
		die 0
	;;
	--uniminin)
		[ -z "$directory" ] && export directory=""
		[ -z "$srcdir" ] && export srcdir="$(pwd)"
		configure_lets
	;;
	"") die 1 "Not Finished" ;;
	*) die 2 "Argument '$1' is not recognized by ${FUNCNAME[0]}"; break
esac; done
