#!/usr/bin/env ksh
SOURCE_DIR=$(dirname $0)
ZABBIX_DIR=/etc/zabbix

mkdir -p ${ZABBIX_DIR}/scripts/agentd/zaldap
cp -r ${SOURCE_DIR}/zaldap/queries ${ZABBIX_DIR}/scripts/agentd/zaldap/
cp ${SOURCE_DIR}/zaldap/zaldap.conf.example ${ZABBIX_DIR}/scripts/agentd/zaldap/
cp ${SOURCE_DIR}/zaldap/zaldap.sh ${ZABBIX_DIR}/scripts/agentd/zaldap/
cp ${SOURCE_DIR}/zaldap/zabbix_agentd.conf ${ZABBIX_DIR}/zabbix_agentd.d/zaldap.conf
