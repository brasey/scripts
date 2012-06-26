#!/usr/bin/perl

use strict;
use warnings;

my @files = qw(
tx-websvc01.csv
tx-websvc02.csv
tx-websvc03.csv
tx-websvc04.csv
tx-websvc05.csv
);

my %app_names = (
asaws		=> 'AdesaSmartAuction',
AIWS		=> 'Attachment',
AUCTION		=> 'AuctionInfo',
airws		=> 'AuctionInventoryRegistration',
aws		=> 'Authentication',
blobws		=> 'BlobServer',
CarProof	=> 'CarProof',
chargesws	=> 'Charges',
cws		=> 'Credit',
DentWizard	=> 'DentWizardMobileSynchronization',
ecrdataws	=> 'ECRData',
ecrdws		=> 'ECRDisplay',
ecrpricews	=> 'ECRPrice',
ecrvehws	=> 'ECRVeh',
ecrws		=> 'ECR',
feesws		=> 'Fees',
ICS		=> 'InSightComplianceService',
isws		=> 'InventorySearch',
kws		=> 'Kiosk',
LSJL		=> 'LaneserverJMXListener',
mtws		=> 'MMRTransactions',
pbcws		=> 'PriceBookCanada',
pbws		=> 'PriceBook',
pvws		=> 'PurchasedVehicles',
rlnws		=> 'RemoteListingNotification',
sws		=> 'SalvageInfo',
spws		=> 'SpecialPricing',
webservices	=> 'TRACrawler',
tws		=> 'Transaction',
uccw		=> 'UserChangeCrawlerWeb',
uws		=> 'User',
vdws		=> 'VehicleDecoder',
vdbuws		=> 'VINDecoderBulkUpdate',
VID		=> 'VinStyleIDtoMID',
INSP		=> 'InspectionSolutions'
);

for my $file (@files) {
	open F, $file or die "Couldn't open $file for reading: $!\n";
	my $outfile = $file . ".new";
	open O, "> $outfile" or die "Couldn't open $outfile for writing: $!\n";
	
	while (<F>) {
		for my $match (keys %app_names) {
			if ( $_ =~ /,$match.*?,/ ) {
				$_ =~ s/,$match.*?,/,$app_names{$match},/;
				print O $_;
				last;
			}
			elsif ( $_ =~ /,ecrpricews-PROD-tx-websvc04-2,/ ) {
				$_ =~ s/,ecrpricews-PROD-tx-websvc04-2,/,ECRPrice\/2,/;
				print O $_;
				last;
			}
			elsif ( $_ =~ /,ecrvehws-PROD-tx-websvc05-2,/ ) {
				# This is a stupid hack
				# They have two instances running in the same directory
				# Luckily, the PID remained consistent for the duration
				if ( $_ =~ /,17297,/ ) {
					$_ =~ s/,ecrvehws-PROD-tx-websvc05-2,/,ECRVeh\/2,/;
					print O $_;
					last;
				}
				elsif ( $_ =~ /,18556,/ ) {
					$_ =~ s/,ecrvehws-PROD-tx-websvc05-2,/,ECRVeh\/3,/;
					print O $_;
					last;
				}
			}
			elsif ( $_ =~ /,15206,LSJL-PROD-tx-websvc04-1,/ ) {
				# This is a stupid hack
				# I didn't capture one appname correctly, so it's named
				# the same as another app
				# Luckily, the PID remained consistent for the duration
				$_ =~ s/,LSJL-PROD-tx-websvc04-1,/,MAFS,/;
				print O $_;
			}
			elsif ( $_ =~ /,7174,webservices\.manheim\.com,/ ) {
				# This is a stupid hack
				# I didn't capture one appname correctly, so it's named
				# the same as another app
				# Luckily, the PID remained consistent for the duration
				$_ =~ s/,webservices\.manheim\.com,/,MAFS,/;
				print O $_;
			}
		}
	}
	close O;
	close F;
}
