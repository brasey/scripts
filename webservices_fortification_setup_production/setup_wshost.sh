#!/bin/bash

HOSTNAME=`hostname`
ENVIRONMENT="PROD"
CLUSTER=${HOSTNAME:9:2}
WS_ROOT='/export/webservices.manheim.com'
FILE_SOURCE='10.145.11.33'
FILE_SOURCE_HOSTNAME='tx-websvc01'
DMZ_FILE_SOURCE_HOSTNAME='tx-websvc04'

case $CLUSTER in
	01)
		WEBSERVICES="AdesaSmartAuction AuctionInfoWebService AuthenticationWebService BlobServerWebService CreditWebService DentWizardMobileSynchronizationWebServices ECRWebService PurchasedVehiclesWebService SpecialPricingWebService UserWebService VehicleDecoderWebService"
		;;
	02)
		WEBSERVICES="ChargesWebService ECRDataWebServices ECRDisplayWebService ECRPriceWebServices ECRVehWebServices FeesWebService InSightComplianceService InspectionSolutionsWebService MAFSWebservices SalvageInfoWebService TRACrawler UserChangeCrawlerWeb VINDecoderBulkUpdateWebService VinStyleIDtoMIDWebservice"
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

	if [ $WEBSERVICE = "ECRWebService" ]; then
		# File source dir structure has different name
		rsync -ave ssh --exclude=temp/* --exclude=work/* \
			root@$FILE_SOURCE:$WS_ROOT/ECRWebService/$FILE_SOURCE_HOSTNAME/ \
			$WS_ROOT/$WEBSERVICE/$HOSTNAME/

	elif [ $WEBSERVICE = "VinStyleIDtoMIDWebservice" ]; then
		# File source dir structure has different name
		rsync -ave ssh --exclude=temp/* --exclude=work/* \
			root@$FILE_SOURCE:$WS_ROOT/VinStyleIDtoMIDWebService/$DMZ_FILE_SOURCE_HOSTNAME/ \
			$WS_ROOT/$WEBSERVICE/$HOSTNAME/

	elif ssh $FILE_SOURCE ls -d $WS_ROOT/$WEBSERVICE/$FILE_SOURCE_HOSTNAME > /dev/null; then
		# Inside Production web services
		rsync -ave ssh --exclude=temp/* --exclude=work/* \
			root@$FILE_SOURCE:$WS_ROOT/$WEBSERVICE/$FILE_SOURCE_HOSTNAME/ \
			$WS_ROOT/$WEBSERVICE/$HOSTNAME/

	elif ssh $FILE_SOURCE ls -d $WS_ROOT/$WEBSERVICE/$DMZ_FILE_SOURCE_HOSTNAME > /dev/null; then 
		# DMZ Production web services
		rsync -ave ssh --exclude=temp/* --exclude=work/* \
			root@$FILE_SOURCE:$WS_ROOT/$WEBSERVICE/$DMZ_FILE_SOURCE_HOSTNAME/ \
			$WS_ROOT/$WEBSERVICE/$HOSTNAME/
	fi

	# Cleanup
	if [ ! -e $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive ]; then
		mkdir $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive
	fi
	mv $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/* $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/archive

done

groupadd webservices
chown -v -R webservices:webservices $WS_ROOT
find $WS_ROOT -type d -print0 | xargs -0 chmod -v 0775
find $WS_ROOT -type f -print0 | xargs -0 chmod -v 0664
find $WS_ROOT -type f -name "*\.sh" -print0 | xargs -0 chmod -v 0775

for WEBSERVICE in $WEBSERVICES; do
	if [ $WEBSERVICE = "SpecialPricingWebService"]; then
		echo $WS_ROOT/specialPricingWebService/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices
		$INIT_SCRIPT = "/etc/init.d/specialPricingWebService"
		$CONFIG_FILE = "/etc/sysconfig/specialPricingWebService"
		
	elif [ $WEBSERVICE = "SalvageInfoWebService"]; then
		echo $WS_ROOT/salvageInfoWebService/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices
		$INIT_SCRIPT = "/etc/init.d/salvageInfoWebService"
		$CONFIG_FILE = "/etc/sysconfig/salvageInfoWebService"

	elif [ $WEBSERVICE = "KioskWebService"]; then
		echo $WS_ROOT/kioskWebService/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices
		$INIT_SCRIPT = "/etc/init.d/kioskWebService"
		$CONFIG_FILE = "/etc/sysconfig/kioskWebService"

	else
		echo $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/logs/catalina.out >> /etc/logrotate.d/webservices
		$INIT_SCRIPT = "/etc/init.d/$WEBSERVICE"
		$CONFIG_FILE = "/etc/sysconfig/$WEBSERVICE"
	fi

	ln -s /etc/init.d/tomcat6 $INIT_SCRIPT

	source ws_attributes_pro.sh

	echo "# These variables will change from host to host and environment to environment" >> $CONFIG_FILE
	echo "WS_BASE=\"$WS_ROOT\"" >> $CONFIG_FILE
	echo "WS_NAME=\"$WEBSERVICE\"" >> $CONFIG_FILE
	echo "WS_SHORTNAME=\"$WS_SHORTNAME\"" >> $CONFIG_FILE
	echo "CONNECTOR_PORT=\"$CONNECTOR_PORT\"" >> $CONFIG_FILE
	echo "ENVIRONMENT=\"$ENVIRONMENT\"" >> $CONFIG_FILE
	echo "TOMCAT_USER=\"webservices\"" >> $CONFIG_FILE
	echo "XMS=\"-Xms${XMS}m\"" >> $CONFIG_FILE
	echo "XMX=\"-Xmx${XMX}m\"" >> $CONFIG_FILE

	cat $CONFIG_FILE ws_config.template > $CONFIG_FILE.new
	mv $CONFIG_FILE.new $CONFIG_FILE

	chgrp webservices $CONFIG_FILE
	chmod g+w $CONFIG_FILE

	$INIT_SCRIPT start

	if [ $WEBSERVICE = "SpecialPricingWebService"]; then
		chkconfig specialPricingWebService on
		
	elif [ $WEBSERVICE = "SalvageInfoWebService"]; then
		chkconfig salvageInfoWebService on

	elif [ $WEBSERVICE = "KioskWebService"]; then
		chkconfig kioskWebService on

	else
		chkconfig $WEBSERVICE on
	fi

	if [ -z "$WEBSERVICE_LIST" ]; then
		WEBSERVICE_LIST+="$INIT_SCRIPT"
	else
		WEBSERVICE_LIST+=", $INIT_SCRIPT"
	fi
done

cat logrotate.txt >> /etc/logrotate.d/webservices

echo >> /etc/sudoers
echo "# Manheim sudo config" >> /etc/sudoers
echo "Cmnd_Alias WEBSERVICES = $WEBSERVICE_LIST" >> /etc/sudoers
echo "%webservices	ALL=NOPASSWD: WEBSERVICES" >> /etc/sudoers

usermod -g webservices webservices
