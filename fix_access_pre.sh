#!/bin/bash

# WS_ROOT
# Specify where the web services live. Varies between environments.
#
# DEV and ETEQA
#WS_ROOT='/export/webservices'
# PRE
WS_ROOT='/export/webservices.developer.manheim.com'

# WEBSERVICES
# Each cluster gets a specified subset of web services. Uncomment the appropriate cluster.
#
# CLUSTER 1
#WEBSERVICES="AdesaSmartAuction AuctionInfoWebService AuthenticationWebService BlobServerWebService CreditWebService DentWizardMobileSynchronizationWebServices ECRWebServices PurchasedVehiclesWebService SpecialPricingWebService UserWebService VehicleDecoderWebService"
# CLUSTER 2
#WEBSERVICES="ChargesWebService ECRDataWebServices ECRDisplayWebService ECRPriceWebServices ECRVehWebServices FeesWebService InSightComplianceService InspectionSolutions MAFSWebservices SalvageInfoWebService TRACrawler UserChangeCrawlerWeb VINDecoderBulkUpdateWebService VinStyleIDtoMIDWebService"
# CLUSTER 3
#WEBSERVICES="AttachmentWebService"
# CLUSTER 4
#WEBSERVICES="AuctionInventoryRegistrationWebService"
# CLUSTER 5
#WEBSERVICES="InventorySearchWebService"
# CLUSTER 6
#WEBSERVICES="KioskWebService"
# CLUSTER 7
#WEBSERVICES="LaneserverJMXListener"
# CLUSTER 8
#WEBSERVICES="MMRTransactionsWebService PriceBookCanadaWebService PriceBookWebService"
# CLUSTER 9
#WEBSERVICES="RemoteListingNotificationWebService"
# CLUSTER 10
WEBSERVICES="TransactionWebService"
# CLUSTER 11
#WEBSERVICES="CarProof"

usermod -a -G webservices kgatdula
usermod -a -G webservices jwynne
usermod -a -G webservices jreddick
usermod -a -G webservices rrohan
usermod -a -G webservices fschmidt

for WEBSERVICE in $WEBSERVICES; do
	if [ -z "$WEBSERVICE_LIST" ]; then
		WEBSERVICE_LIST+="/etc/init.d/$WEBSERVICE"
	else
		WEBSERVICE_LIST+=", /etc/init.d/$WEBSERVICE"
	fi
	chkconfig $WEBSERVICE on
done

echo >> /etc/sudoers
echo "# Manheim sudo config" >> /etc/sudoers
echo "Cmnd_Alias WEBSERVICES = $WEBSERVICE_LIST" >> /etc/sudoers
echo "%webservices      localhost=NOPASSWD: WEBSERVICES" >> /etc/sudoers
