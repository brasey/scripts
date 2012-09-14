#!/bin/bash

# Important!
# If web service name starts with K or S, make sure to
# rename the /etc/init.d symlink and the /etc/sysconfig
# configuration file so they start with a lower case 
# 'k' or 's'. If you leave them capitalized, the service
# won't start and files will break.

if [ -z $1 ]; then echo "Wnat is the name of the webservice to add?" && exit; fi

HOSTNAME=`hostname`
WEBSERVICE=$1

if [ ${HOSTNAME:0:1} = 'q' ]; then
	# QA environment 
	INSTANCE=${HOSTNAME:11:1}
	ENVIRONMENT="ETEQA$INSTANCE"
	WS_ROOT='/export/webservices'
else
	# All other environments
	ENVIRONMENT=${HOSTNAME:0:3}
	ENVIRONMENT="`echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]'`"
fi

case $ENVIRONMENT in 
	DEV)
		WS_ROOT='/export/webservices'
		;;
	PRE)
		WS_ROOT='/export/webservices.developer.manheim.com'
		ENVIRONMENT="PREPROD"
		;;
esac

mkdir -v -p $WS_ROOT/$WEBSERVICE/$HOSTNAME/1

echo $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices.tmp
cat /etc/logrotate.d/webservices >> /etc/logrotate.d/webservices.tmp
mv /etc/logrotate.d/webservices.tmp /etc/logrotate.d/webservices

ln -s /etc/init.d/tomcat6 /etc/init.d/$WEBSERVICE

echo "# These variables will change from host to host and environment to environment" >> /etc/sysconfig/$WEBSERVICE
echo "WS_BASE=\"$WS_ROOT\"" >> /etc/sysconfig/$WEBSERVICE
echo "WS_NAME=\"$WEBSERVICE\"" >> /etc/sysconfig/$WEBSERVICE
echo "WS_SHORTNAME=\"\"" >> /etc/sysconfig/$WEBSERVICE
echo "CONNECTOR_PORT=\"\"" >> /etc/sysconfig/$WEBSERVICE
echo "ENVIRONMENT=\"$ENVIRONMENT\"" >> /etc/sysconfig/$WEBSERVICE
echo "TOMCAT_USER=\"webservices\"" >> /etc/sysconfig/$WEBSERVICE
echo "XMS=\"-Xms256m\"" >> /etc/sysconfig/$WEBSERVICE
echo "XMX=\"-Xmx256m\"" >> /etc/sysconfig/$WEBSERVICE

cat /etc/sysconfig/$WEBSERVICE ws_config.template > /etc/sysconfig/$WEBSERVICE.new
mv /etc/sysconfig/$WEBSERVICE.new /etc/sysconfig/$WEBSERVICE

chgrp webservices /etc/sysconfig/$WEBSERVICE
chmod g+w /etc/sysconfig/$WEBSERVICE

chkconfig $WEBSERVICE on

sed -i "s#^\(Cmnd_Alias WEBSERVICES.*\)#\1, /etc/init.d/$WEBSERVICE#" /etc/sudoers

cp -a /usr/share/tomcat6/conf $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/conf
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/webapps
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/temp
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/work
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/shared
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/server
mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/common
chown -v -R webservices:webservices $WS_ROOT/$WEBSERVICE

echo
echo "Don't forget to edit $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/conf/server.xml and set a unique Connector port!"
echo
