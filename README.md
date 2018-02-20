# zaldap


# Monitor configuration via cn=config(5)

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
    
# Zabbix deploy

    #~ git clone https://github.com/sergiotocalini/zaldap.git
    #~ cd zaldap
    #~ ./deploy_zabbix.sh
    
    
