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
GAWK=`which gawk`
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
    echo "\nOptions:"
    echo "  -D ARG(str)          Bind DN."
    echo "  -H,--host ARG(str)   LDAP server."
    echo "  -h,--help            Displays this help message."
    echo "  -q,--query ARG(str)  Query to OpenLDAP."
    echo "  -v,--version         Show the script version"
    echo "  -w ARG(str)          Bind password.\n"
    if [[ ${query} = 1 ]]; then
	usage_query
    else
	echo "For a full list of supported queries run: ${APP_NAME%.*} -h query"
    fi
    echo "Please send any bug reports to sergiotocalini@gmail.com"
    exit 1
}

usage_query() {
   echo "Query's:"
   echo "  connections_current     -- Connections - Current."
   echo "  connections_total       -- Connections - Total."
   echo "  oper_completed_abandon  -- Operations Completed - Abandon."
   echo "  oper_completed_add      -- Operations Completed - Add."
   echo "  oper_completed_bind     -- Operations Completed - Bind."
   echo "  oper_completed_compare  -- Operations Completed - Compare."
   echo "  oper_completed_delete   -- Operations Completed - Delete."
   echo "  oper_completed_extended -- Operations Completed - Extended."
   echo "  oper_completed_modify   -- Operations Completed - Modify."
   echo "  oper_completed_modrdn   -- Operations Completed - Modrdn."
   echo "  oper_completed_search   -- Operations Completed - Search."
   echo "  oper_completed_unbind   -- Operations Completed - Unbind."
   echo "  oper_initiated_abandon  -- Operations Initiated - Abandon."
   echo "  oper_initiated_add      -- Operations Initiated - Add."
   echo "  oper_initiated_bind     -- Operations Initiated - Bind."
   echo "  oper_initiated_compare  -- Operations Initiated - Compare."
   echo "  oper_initiated_delete   -- Operations Initiated - Delete."
   echo "  oper_initiated_extended -- Operations Initiated - Extended."
   echo "  oper_initiated_modify   -- Operations Initiated - Modify."
   echo "  oper_initiated_modrdn   -- Operations Initiated - Modrdn."
   echo "  oper_initiated_search   -- Operations Initiated - Search."
   echo "  oper_initiated_unbind   -- Operations Initiated - Unbind."
   echo "  stats_bytes             -- Statistics - Bytes."
   echo "  stats_entries           -- Statistics - Entries."
   echo "  stats_pdu               -- Statistics - PDU."
   echo "  stats_referrals         -- Statistics - Referrals."
   echo "  threads_active          -- Threads - Active."
   echo "  threads_max             -- Threads - Max."
   echo "  threads_max_pending     -- Threads - Max Pending."
   echo "  threads_open            -- Threads - Open."
   echo "  threads_pending         -- Threads - Pending."
   echo "  threads_starting        -- Threads - Starting."
   echo "  waiters_read            -- Waiters - Read."
   echo "  waiters_write           -- Waiters - Write."
   echo "  uptime                  -- OpenLDAP - Uptime"
   echo "  version                 -- OpenLDAP - Version.\n"
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

load_profile() {
    while IFS='=' read opt value; do
	if [ ${opt} = 'binddn' ]; then
	    binddn=${value}
	elif [ ${opt} = 'bindpw' ]; then
	    bindpw=${value}
	fi
    done < ${APP_DIR}/auth.info
}

getBaseDN() {
    case $1 in
	'connections_current')
	    basedn="cn=Current,cn=Connections,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'connections_total')
	    basedn="cn=Total,cn=Connections,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'oper_completed_abandon')
	    basedn="cn=Abandon,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_add')
	    basedn="cn=Add,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_bind')
	    basedn="cn=Bind,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_compare')
	    basedn="cn=Compare,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_delete')
	    basedn="cn=Delete,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_extended')
	    basedn="cn=Extended,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_modify')
	    basedn="cn=Modify,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_modrdn')
	    basedn="cn=Modrdn,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_search')
	    basedn="cn=Search,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_completed_unbind')
	    basedn="cn=Unbind,cn=Operations,cn=Monitor"
	    attrs="monitorOpCompleted"
	    ;;
	'oper_initiated_abandon')
	    basedn="cn=Abandon,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_add')
	    basedn="cn=Add,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_bind')
	    basedn="cn=Bind,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_compare')
	    basedn="cn=Compare,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_delete')
	    basedn="cn=Delete,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_extended')
	    basedn="cn=Extended,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_modify')
	    basedn="cn=Modify,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_modrdn')
	    basedn="cn=Modrdn,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_search')
	    basedn="cn=Search,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'oper_initiated_unbind')
	    basedn="cn=Unbind,cn=Operations,cn=Monitor"
	    attrs="monitorOpInitiated"
	    ;;
	'stats_bytes')
	    basedn="cn=Bytes,cn=Statistics,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'stats_entries')
	    basedn="cn=Entries,cn=Statistics,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'stats_pdu')
	    basedn="cn=PDU,cn=Statistics,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'stats_referrals')
	    basedn="cn=Referrals,cn=Statistics,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'threads_active')
	    basedn="cn=Active,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'threads_max')
	    basedn="cn=Max,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'threads_max_pending')
	    basedn="cn=Max Pending,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'threads_open')
	    basedn="cn=Open,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'threads_pending')
	    basedn="cn=Pending,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'threads_starting')
	    basedn="cn=Starting,cn=Threads,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'waiters_read')
	    basedn="cn=Read,cn=Waiters,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'waiters_write')
	    basedn="cn=Write,cn=Waiters,cn=Monitor"
	    attrs="monitorCounter"
	    ;;
	'uptime')
	    basedn="cn=Uptime,cn=Time,cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
	'version')
	    basedn="cn=Monitor"
	    attrs="monitoredInfo"
	    ;;
    esac
    if [[ -n ${basedn} && -n ${attrs} ]];then
	echo "${basedn};${attrs}"
    fi
}
#
#################################################################################

#################################################################################
count=0
for x in "${@}"; do
    ARG[$count]="$x"
    let "count=count+1"
done

count=1
for i in "${ARG[@]}"; do
    case "${i}" in
	-h|--help)
	    if [[ ${ARG[$count]} = "query" ]]; then
		usage 1
	    else
		usage 0
	    fi
	    ;;
	-q|--query)
	    QUERY=${ARG[$count]}
	    ;;
	-H)
	    host=${ARG[$count]}
	    ;;
	-D)
	    binddn=${ARG[$count]}
	    ;;
	-w)
	    bindpw=${ARG[$count]}
	    ;;
	-v|--version)
	    if [[ ${ARG[$count]} = "short" ]]; then
		version 1
	    else
		version 0
	    fi
	    ;;
    esac
    let "count=count+1"
done

output=$(getBaseDN "${QUERY}")
if [[ -n "${output}" ]]; then
    if [[ -z ${binddn} && -z ${bindpw} ]];then
	load_profile
    fi
    basedn=`echo ${output}|${GAWK} -F ";" '{print $1}'`
    attrs=`echo ${output}|${GAWK} -F ";" '{print $2}'`
    ldapsearch -x -h "${host}" -D ${binddn} -w ${bindpw} -b "${basedn}" -s base "(objectclass=*)" "${attrs}"|grep "^${attrs}"|${GAWK} -v value="${attrs}: " '{sub(value,""); print $0}'
    rval="${?}"
    if [[ "$rval" -ne 0 ]]; then
	echo "0"
    fi
else
    echo "ZBX_NOTSUPPORTED"
    rval="1"
fi

exit ${rval}
