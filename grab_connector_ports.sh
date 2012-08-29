#!/bin/bash

HOSTNAME=`hostname`
WS_ROOT="/export/webservices.developer.manheim.com"
WEBSERVICES="AdesaSmartAuction AttachmentWebService AuctionInfoWebService AuctionInventoryRegistrationWebService AuthenticationWebService BlobServerWebService CarProof ChargesWebService CreditWebService DentWizardMobileSynchronizationWebServices ECRDataWebServices ECRDisplayWebService ECRPriceWebServices ECRVehWebServices ECRWebService FeesWebService InSightComplianceService InspectionSolutionsWebService InventorySearchWebService KioskWebService LaneserverJMXListener MAFSWebservices MMRTransactionsWebService PriceBookCanadaWebService PriceBookWebService PurchasedVehiclesWebService RemoteListingNotificationWebService SalvageInfoWebService SpecialPricingWebService TRACrawler TransactionWebService UserChangeCrawlerWeb UserWebService VehicleDecoderWebService VINDecoderBulkUpdateWebService VinStyleIDtoMIDWebservice" 

echo #!/bin/bash
echo
echo 'case $WEBSERVICE in'

for WEBSERVICE in $WEBSERVICES; do
	WS_ABBR=''
	CONNECTOR_PORT=''
	WS_XMS=''
	WS_XMX=''

	if [ -e $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/setenv.sh ]; then
		WS_ABBR=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/setenv.sh | grep WS_ABBR= | sed -e 's/.*=\([a-zA-Z]*\).*/\1/'`
		WS_XMS=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/setenv.sh | grep WS_XMS= | sed -e 's/.*=//'`
		WS_XMX=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/setenv.sh | grep WS_XMX= | sed -e 's/.*=//'`
	elif [ -e $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/set-webservices-env.sh ]; then
		WS_ABBR=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/set-webservices-env.sh | grep WS_ABBR= | sed -e 's/.*=\([a-zA-Z]*\).*/\1/'`
		WS_XMS=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/set-webservices-env.sh | grep WS_XMS= | sed -e 's/.*=//'`
		WS_XMX=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/bin/set-webservices-env.sh | grep WS_XMX= | sed -e 's/.*=//'`
	else
		echo No setenv.sh found for $WEBSERVICE.
	fi

	WS_ABBR=`echo $WS_ABBR | tr '[:upper:]' '[:lower:]'`
	WS_XMS=${WS_XMS:-256}
	WS_XMX=${WS_XMX:-256}

	if [ -e $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/conf/server.xml ]; then
		WS_CONN=`cat $WS_ROOT/$WEBSERVICE/$HOSTNAME/1/conf/server.xml | grep -H Connector | sed -e 's/.*"\([0-9]*\)".*/\1/'`
	else
		echo No server.xml found for $WEBSERVICE.
	fi

	echo "	$WEBSERVICE)"
	echo "		WS_SHORTNAME=\"$WS_ABBR\""
	echo "		CONNECTOR_PORT=\"$WS_CONN\""
	echo "		XMS=\"$WS_XMS\""
	echo "		XMX=\"$WS_XMX\""
	echo "		;;"
done

echo esac
