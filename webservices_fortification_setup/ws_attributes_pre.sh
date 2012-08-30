#!/bin/bash

case $WEBSERVICE in
	AdesaSmartAuction)
		WS_SHORTNAME="asaws"
		CONNECTOR_PORT="9289"
		XMS="256"
		XMX="256"
		;;
	AttachmentWebService)
		WS_SHORTNAME="atws"
		CONNECTOR_PORT="9445"
		XMS="256"
		XMX="256"
		;;
	AuctionInfoWebService)
		WS_SHORTNAME="aiws"
		CONNECTOR_PORT="19630"
		XMS="256"
		XMX="256"
		;;
	AuctionInventoryRegistrationWebService)
		WS_SHORTNAME="airws"
		CONNECTOR_PORT="9309"
		XMS="256"
		XMX="256"
		;;
	AuthenticationWebService)
		WS_SHORTNAME="aws"
		CONNECTOR_PORT="19282"
		XMS="256"
		XMX="256"
		;;
	BlobServerWebService)
		WS_SHORTNAME="bsws"
		CONNECTOR_PORT="19288"
		XMS="64"
		XMX="256"
		;;
	CarProof)
		WS_SHORTNAME="carproof"
		CONNECTOR_PORT="19311"
		XMS="256"
		XMX="256"
		;;
	ChargesWebService)
		WS_SHORTNAME="chgws"
		CONNECTOR_PORT="19354"
		XMS="32"
		XMX="64"
		;;
	CreditWebService)
		WS_SHORTNAME="cws"
		CONNECTOR_PORT="443"
		XMS="256"
		XMX="256"
		;;
	DentWizardMobileSynchronizationWebServices)
		WS_SHORTNAME="dwmsws"
		CONNECTOR_PORT="9291"
		XMS="256"
		XMX="1024"
		;;
	ECRDataWebServices)
		WS_SHORTNAME="ecrdws"
		CONNECTOR_PORT="19001"
		XMS="64"
		XMX="1024"
		;;
	ECRDisplayWebService)
		WS_SHORTNAME="ecrdws"
		CONNECTOR_PORT="19313"
		XMS="64"
		XMX="256"
		;;
	ECRPriceWebServices)
		WS_SHORTNAME="ecrpws"
		CONNECTOR_PORT="19003"
		XMS="64"
		XMX="1024"
		;;
	ECRVehWebServices)
		WS_SHORTNAME="ecrvws"
		CONNECTOR_PORT="19007"
		XMS="64"
		XMX="1024"
		;;
	ECRWebservice)
		WS_SHORTNAME="ecr"
		CONNECTOR_PORT="19007"
		XMS="256"
		XMX="256"
		;;
	FeesWebService)
		WS_SHORTNAME="feesws"
		CONNECTOR_PORT="19324"
		XMS="32"
		XMX="32"
		;;
	InSightComplianceService)
		WS_SHORTNAME="ics"
		CONNECTOR_PORT="9460"
		XMS="256"
		XMX="256"
		;;
	InspectionSolutionsWebService)
		WS_SHORTNAME="insp"
		CONNECTOR_PORT="9462"
		XMS="256"
		XMX="256"
		;;
	InventorySearchWebService)
		WS_SHORTNAME="isws"
		CONNECTOR_PORT="19401"
		XMS="512"
		XMX="512"
		;;
	KioskWebService)
		WS_SHORTNAME="kioskws"
		CONNECTOR_PORT="9421"
		XMS="256"
		XMX="256"
		;;
	LaneserverJMXListener)
		WS_SHORTNAME="lsjl"
		CONNECTOR_PORT="19417"
		XMS="256"
		XMX="256"
		;;
	MAFSWebservices)
		WS_SHORTNAME="maw"
		CONNECTOR_PORT="9457"
		XMS="256"
		XMX="256"
		;;
	MMRTransactionsWebService)
		WS_SHORTNAME="mtws"
		CONNECTOR_PORT="19407"
		XMS="256"
		XMX="256"
		;;
	PriceBookCanadaWebService)
		WS_SHORTNAME="pbcws"
		CONNECTOR_PORT="19233"
		XMS="256"
		XMX="256"
		;;
	PriceBookWebService)
		WS_SHORTNAME="pbws"
		CONNECTOR_PORT="19283"
		XMS="256"
		XMX="256"
		;;
	PurchasedVehiclesWebService)
		WS_SHORTNAME="pvws"
		CONNECTOR_PORT="19295"
		XMS="256"
		XMX="256"
		;;
	RemoteListingNotificationWebService)
		WS_SHORTNAME="rlnws"
		CONNECTOR_PORT="9211"
		XMS="256"
		XMX="256"
		;;
	SalvageInfoWebService)
		WS_SHORTNAME="siws"
		CONNECTOR_PORT="9377"
		XMS="256"
		XMX="256"
		;;
	SpecialPricingWebService)
		WS_SHORTNAME="spws"
		CONNECTOR_PORT="19231"
		XMS="256"
		XMX="256"
		;;
	TRACrawler)
		WS_SHORTNAME="trac"
		CONNECTOR_PORT="31012"
		XMS="256"
		XMX="512"
		;;
	TransactionWebService)
		WS_SHORTNAME="tws"
		CONNECTOR_PORT="19212"
		XMS="256"
		XMX="256"
		;;
	UserChangeCrawlerWeb)
		WS_SHORTNAME="uccw"
		CONNECTOR_PORT="19303"
		XMS="256"
		XMX="256"
		;;
	UserWebService)
		WS_SHORTNAME="uws"
		CONNECTOR_PORT="19296"
		XMS="256"
		XMX="256"
		;;
	VehicleDecoderWebService)
		WS_SHORTNAME="vdws"
		CONNECTOR_PORT="19073"
		XMS="256"
		XMX="256"
		;;
	VINDecoderBulkUpdateWebService)
		WS_SHORTNAME="vdbuws"
		CONNECTOR_PORT="19217"
		XMS="64"
		XMX="256"
		;;
	VinStyleIDtoMIDWebservice)
		WS_SHORTNAME="vid"
		CONNECTOR_PORT="9021"
		XMS="256"
		XMX="256"
		;;
esac
