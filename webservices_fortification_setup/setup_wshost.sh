#!/bin/bash

# Important!
# If web service name starts with K or S, make sure to
# rename the /etc/init.d symlink and the /etc/sysconfig
# configuration file so they start with a lower case 
# 'k' or 's'. If you leave them capitalized, the service
# won't start and files will break.

HOSTNAME=`hostname`

if [ ${HOSTNAME:0:1} = 'q' ]; then
	# QA environment 
	CLUSTER=${HOSTNAME:8:2}
	INSTANCE=${HOSTNAME:11:1}
	ENVIRONMENT="ETEQA$INSTANCE"
	WS_ROOT='/export/webservices'
	FILE_SOURCE='10.129.130.50'
	FILE_SOURCE_HOSTNAME='app-ind.man.qa'
else
	# All other environments
	ENVIRONMENT=${HOSTNAME:0:3}
	CLUSTER=${HOSTNAME:9:2}
	ENVIRONMENT="`echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]'`"
fi

case $ENVIRONMENT in 
	DEV)
		WS_ROOT='/export/webservices'
		FILE_SOURCE='10.100.204.188'
		FILE_SOURCE_HOSTNAME='cp-wsdev01'
		;;
	PRE)
		WS_ROOT='/export/webservices.developer.manheim.com'
		FILE_SOURCE='10.100.204.77'
		FILE_SOURCE_HOSTNAME='cp-appstage01'
		ENVIRONMENT="PREPROD"
		;;
esac

case $CLUSTER in
	01)
		WEBSERVICES="AdesaSmartAuction AuctionInfoWebService AuthenticationWebService BlobServerWebService CreditWebService DentWizardMobileSynchronizationWebServices ECRWebservice PurchasedVehiclesWebService SpecialPricingWebService UserWebService VehicleDecoderWebService"
		;;
	02)
		WEBSERVICES="ChargesWebService ECRDataWebServices ECRDisplayWebService ECRPriceWebServices ECRVehWebServices FeesWebService InSightComplianceService InspectionSolutions MAFSWebservices SalvageInfoWebService TRACrawler UserChangeCrawlerWeb VINDecoderBulkUpdateWebService VinStyleIDtoMIDWebService"
		;;
	03)
		WEBSERVICES="AttachmentWebService"
		;;
	04)
		WEBSERVICES="AuctionInventoryRegistrationWebService"
		;;
	05)
		WEBSERVICES="InventorySearchWebService"
		;;
	06)
		WEBSERVICES="KioskWebService"
		;;
	07)
		WEBSERVICES="LaneserverJMXListener"
		;;
	08)
		WEBSERVICES="MMRTransactionsWebService PriceBookCanadaWebService PriceBookWebService"
		;;
	09)
		WEBSERVICES="RemoteListingNotificationWebService"
		;;
	10)
		WEBSERVICES="TransactionWebService"
		;;
	11)
		WEBSERVICES="CarProof"
		;;
esac

parted /dev/sdb mklabel msdos
parted /dev/sdb unit % mkpart primary ext2 0 100
parted /dev/sdb set 1 lvm on
partprobe /dev/sdb

pvcreate /dev/sdb1
vgcreate wsvg /dev/sdb1
lvcreate -n webservice -l 100%FREE wsvg

mkfs.ext4 /dev/wsvg/webservice

LINE=`blkid | grep webservice | cut -d ' ' -f 2`
LINE+=" $WS_ROOT ext4 defaults 0 0"
echo $LINE >> /etc/fstab

mkdir -v $WS_ROOT
mount -v $WS_ROOT

for WEBSERVICE in $WEBSERVICES; do
	mkdir -v -p $WS_ROOT/$WEBSERVICE/$HOSTNAME/
	rsync -ave ssh --exclude=temp/* --exclude=work/* root@$FILE_SOURCE:$WS_ROOT/$WEBSERVICE/$FILE_SOURCE_HOSTNAME/ $WS_ROOT/$WEBSERVICE/$HOSTNAME/

	# Cleanup
	if [ ! -e $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive ]; then
		mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive
	fi
	mv $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/* $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive
done

chown -v -R webservices:webservices $WS_ROOT
find $WS_ROOT -type d -print0 | xargs -0 chmod -v 0775
find $WS_ROOT -type f -print0 | xargs -0 chmod -v 0664
find $WS_ROOT -type f -name "*\.sh" -print0 | xargs -0 chmod -v 0775

for WEBSERVICE in $WEBSERVICES; do
	echo $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices
done

cat logrotate.txt >> /etc/logrotate.d/webservices

for WEBSERVICE in $WEBSERVICES; do
	ln -s /etc/init.d/tomcat6 /etc/init.d/$WEBSERVICE

	case $ENVIRONMENT in
		DEV)
			source ws_attributes_dev.sh
			;;
		ETEQA*)
			source ws_attributes_qa.sh
			;;
		PRE)
			source ws_attributes_pre.sh
			;;
	esac

	echo "# These variables will change from host to host and environment to environment" >> /etc/sysconfig/$WEBSERVICE
	echo "WS_BASE=\"$WS_ROOT\"" >> /etc/sysconfig/$WEBSERVICE
	echo "WS_NAME=\"$WEBSERVICE\"" >> /etc/sysconfig/$WEBSERVICE
	echo "WS_SHORTNAME=\"$WS_SHORTNAME\"" >> /etc/sysconfig/$WEBSERVICE
	echo "CONNECTOR_PORT=\"$CONNECTOR_PORT\"" >> /etc/sysconfig/$WEBSERVICE
	echo "ENVIRONMENT=\"$ENVIRONMENT\"" >> /etc/sysconfig/$WEBSERVICE
	echo "TOMCAT_USER=\"webservices\"" >> /etc/sysconfig/$WEBSERVICE
	echo "XMS=\"$XMS\"" >> /etc/sysconfig/$WEBSERVICE
	echo "XMX=\"$XMX\"" >> /etc/sysconfig/$WEBSERVICE

	cat /etc/sysconfig/$WEBSERVICE ws_config.template > /etc/sysconfig/$WEBSERVICE.new
	mv /etc/sysconfig/$WEBSERVICE.new /etc/sysconfig/$WEBSERVICE

	chgrp webservices /etc/sysconfig/$WEBSERVICE
	chmod g+w /etc/sysconfig/$WEBSERVICE

	chkconfig $WEBSERVICE on
done

for WEBSERVICE in $WEBSERVICES; do
	if [ -z "$WEBSERVICE_LIST" ]; then
		WEBSERVICE_LIST+="/etc/init.d/$WEBSERVICE"
	else
		WEBSERVICE_LIST+=", /etc/init.d/$WEBSERVICE"
	fi
	
done

echo >> /etc/sudoers
echo "# Manheim sudo config" >> /etc/sudoers
echo "Cmnd_Alias WEBSERVICES = $WEBSERVICE_LIST" >> /etc/sudoers
echo "%webservices	ALL=NOPASSWD: WEBSERVICES" >> /etc/sudoers

groupadd webservices
usermod -g webservices webservices
usermod -a -G webservices kgatdula
usermod -a -G webservices jwynne
usermod -a -G webservices jreddick
usermod -a -G webservices rrohan
usermod -a -G webservices fschmidt
