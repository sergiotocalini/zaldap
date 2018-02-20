# zaldap

# 20. Monitor

## 20.1. Monitor configuration via cn=config

    #~ vi monitor_enable.ldif
    dn: cn=module,cn=config
    cn: module
    objectClass: olcModuleList
    olcModuleLoad: back_monitor
    olcModulePath: /usr/lib/ldap

    dn: olcDatabase={2}monitor,cn=config
    objectClass: olcDatabaseConfig
    olcDatabase: {2}monitor
    olcAccess: {0}to * by dn.exact=cn=monitor,ou=auth,dc=example,dc=com manage by * none

    #~ ldapadd -Q -Y EXTERNAL -H ldapi:/// -f monitor_enable.ldif
    #~

## 20.2. Monitor configuration via slapd.conf

    #~ vi /etc/ldap/slapd.conf
    ...
    database monitor
    
    access to *
           by dn.exact=cn=monitor,ou=auth,dc=example,dc=com manage
           by * none
    #~

# Zabbix deploy

    #~ git clone https://github.com/sergiotocalini/zaldap.git
    #~ cd zaldap
    #~ ./deploy_zabbix.sh
    #~
    
    
