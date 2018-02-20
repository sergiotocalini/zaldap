#!/usr/bin/env ksh
#set -x
rval=0

#################################################################################

#################################################################################
#
#  Variable Definition
# ---------------------
#
APP_NAME=`basename ${0}`
APP_DIR=`dirname ${0}`
APP_VER="0.0.1"
APP_WEB="http://www.sergiotocalini.com.ar/"
PATH="${PATH}:/usr/local/bin:/opt/csw/bin:/opt/csw/sbin"
GAWK=`which awk`
#
#################################################################################

#################################################################################
#
#  Load Environment
# ------------------
#
[ -f ${APP_DIR}/${APP_NAME%.*}.conf ] && . ${APP_DIR}/${APP_NAME%.*}.conf

#
#################################################################################

#################################################################################
#
#  Function Definition
# ---------------------
#
usage() {
    query="${1}"
    echo "Usage: ${APP_NAME%.*} [Options]"
    echo ""
    echo "Options:"
    echo "  -D           ARG(str)  Bind DN."
    echo "  -H,--host    ARG(str)  LDAP server."
    echo "  -h,--help              Displays this help message."
    echo "  -q,--query   ARG(str)  Query to OpenLDAP."
    echo "  -v,--version           Show the script version"
    echo "  -w           ARG(str)  Bind password (for simple authentication)."
    if [[ ${query} = 1 ]]; then
	usage_queries
    else
	echo ""
	echo "For a full list of supported queries run: ${APP_NAME%.*} -h query"
	echo ""
    fi
    echo "Please send any bug reports to sergiotocalini@gmail.com"
    exit 1
}

usage_queries() {
    echo ""
    echo "Query's:"
    for i in ${APP_DIR}/queries/*.conf; do
	. ${i}
	echo -e "   ${query}\t\t${comment}"
    done
    echo ""
}

version() {
    version="${1}"
    if [[ ${version} = 1 ]]; then
	echo "${APP_VER}"
    else
	echo "${APP_NAME%.*} ${APP_VER} ( ${APP_WEB} )"
    fi
    exit 1
}

getQuery() {
    query=${1}
    if [[ -f "${query%.conf}.conf" ]]; then
	while read line; do
	    [[ ${line} == '#*' ]] && continue
	    eval ${line}
	done < ${query%.conf}.conf
    else
	return 1
    fi
    return 0
}

#
#################################################################################

#################################################################################
while getopts "vhfsq:H::a::vf::hf" OPTION; do
    case ${OPTION} in
	h)
	    usage 0
	    ;;
	q)
	    QUERY="${APP_DIR}/queries/${OPTARG}"
	    ;;
	H)
	    host=${OPTARG}
	    ;;
	D)
	    binddn=${OPTARG}
	    ;;
	w)
	    bindpw=${OPTARG}
	    ;;
	v)
	    version 1
	    ;;
    esac
done

getQuery "${QUERY}"
if [[ "${?}" == 0 ]]; then
    if [[ -z ${binddn} && -z ${bindpw} ]];then
	usage 0
    fi
    rval=`ldapsearch -x -h "${host}" -D ${binddn} -w ${bindpw} -b "${basedn}" \
    	   	     -s base "(objectclass=*)" "${attrs}"|grep "^${attrs}"|${GAWK} \
		     '{sub(/'${attrs}': /,""); print}'`
    rcode="${?}"
    echo ${rval:-0}
else
    echo "ZBX_NOTSUPPORTED"
    rcode="1"
fi

exit ${rcode}
