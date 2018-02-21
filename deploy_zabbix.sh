#!/usr/bin/env ksh
SOURCE_DIR=$(dirname $0)
ZABBIX_DIR=/etc/zabbix

host=${1:-localhost}
binddn=${2:-cn=monitor,ou=auth,dc=example,dc=com}
bindpw=${3:-xxxxxxxx}

mkdir -p ${ZABBIX_DIR}/scripts/agentd/zaldap
cp -r ${SOURCE_DIR}/zaldap/queries ${ZABBIX_DIR}/scripts/agentd/zaldap/
cp ${SOURCE_DIR}/zaldap/zaldap.conf.example ${ZABBIX_DIR}/scripts/agentd/zaldap/zaldap.conf
cp ${SOURCE_DIR}/zaldap/zaldap.sh ${ZABBIX_DIR}/scripts/agentd/zaldap/
cp ${SOURCE_DIR}/zaldap/zabbix_agentd.conf ${ZABBIX_DIR}/zabbix_agentd.d/zaldap.conf
sed -i "s/host=.*/host=\"${host}\"/g" ${ZABBIX_DIR}/scripts/agentd/zaldap/zaldap.conf
sed -i "s/binddn=.*/binddn=\"${binddn}\"/g" ${ZABBIX_DIR}/scripts/agentd/zaldap/zaldap.conf
sed -i "s/bindpw=.*/bindpw=\"${bindpw}\"/g" ${ZABBIX_DIR}/scripts/agentd/zaldap/zaldap.conf
