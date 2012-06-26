#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';

my @infiles = qw(
tx-websvc01.csv
tx-websvc04.csv
);

my %cluster = ( 
1 => [ 'AdesaSmartAuction','AuctionInfo','Authentication','BlobServer','Credit','DentWizardMobileSynchronization','ECR','PurchasedVehicles','SpecialPricing','User','VehicleDecoder' ],
2 => [ 'Charges','ECRData','ECRDisplay','ECRPrice','ECRVeh','Fees','InSightComplianceService','InspectionSolutions','MAFS','SalvageInfo','TRACrawler','UserChangeCrawlerWeb','VINDecoderBulkUpdate','VinStyleIDtoMID' ],
3 => [ 'Attachment' ],
4 => [ 'AuctionInventoryRegistration' ],
5 => [ 'InventorySearch' ],
6 => [ 'Kiosk' ],
7 => [ 'LaneserverJMXListener' ],
8 => [ 'MMRTransactions','PriceBookCanada','PriceBook' ],
9 => [ 'RemoteListingNotification' ],
10 => [ 'Transaction' ],
11 => [ 'CarProof' ] );


# these hashes are needed in order to ensure columns are in the right order
my %mem;	# hash of hashes to hold memory values for all apps for all time points
		# $mem{timepoint}{app} = value
my %cpu;	# hash of hashes to hold cpu values for all apps for all time points
		# $cpu{timepoint}{app} = value
my %apps;	# hash that contains a list of apps that have run on a host

for my $infile (@infiles) {
	my $firstline = '';	# put header on first row of allmem and allcpu reports

	open F, $infile or die "Couldn't open $infile for read: $!\n";

	$infile =~ /(.+)\.csv/;

	for my $line (<F>) {
		chomp $line;

		my ($time, undef, $app, $mem, $cpu) = split /,/, $line;

		$mem{$time}{$app} = $mem;
		$cpu{$time}{$app} = $cpu;
		$apps{$app}++;
	}
}

my %cluster_mem_header;	# Know when to print the memory header for each cluster

for my $cluster_number (sort keys %cluster) {
	$cluster_mem_header{$cluster_number} = ();

	for my $time (sort keys %mem) {
		# Just show data for May
		next unless $time =~ /^05/;

		my $cluster_memline = $time;
		my $header = 'Time' unless $cluster_mem_header{$cluster_number};

		for my $cluster_app ( @{$cluster{$cluster_number}} ) {

			for my $app (sort keys %apps) {
				next unless $app =~ /^$cluster_app$/;
				$header .= ",$app" unless $cluster_mem_header{$cluster_number};
				$cluster_memline .= ",$mem{$time}->{$app}";
			}

		}

		my $clustermem_file = "cluster" . $cluster_number . "-mem.csv";
		open CLUSTERMEM, ">> $clustermem_file" or die "Couldn't open $clustermem_file for append: $!\n";
		print CLUSTERMEM "$header\n" unless $cluster_mem_header{$cluster_number};
		print CLUSTERMEM "$cluster_memline\n";
		close CLUSTERMEM;
		$cluster_mem_header{$cluster_number} = 1;
	}
}

my %cluster_cpu_header;	# Know when to print the cpu header for each cluster

for my $cluster_number (sort keys %cluster) {
	$cluster_cpu_header{$cluster_number} = ();

	for my $time (sort keys %cpu) {
		# Just show data for May
		next unless $time =~ /^05/;

		my $cluster_cpuline = $time;
		my $header = 'Time' unless $cluster_cpu_header{$cluster_number};

		for my $cluster_app ( @{$cluster{$cluster_number}} ) {

			for my $app (sort keys %apps) {
				next unless $app =~ /^$cluster_app$/;
				$header .= ",$app" unless $cluster_cpu_header{$cluster_number};
				$cluster_cpuline .= ",$cpu{$time}->{$app}";
			}

		}

		my $clustercpu_file = "cluster" . $cluster_number . "-cpu.csv";
		open CLUSTERCPU, ">> $clustercpu_file" or die "Couldn't open $clustercpu_file for append: $!\n";
		print CLUSTERCPU "$header\n" unless $cluster_cpu_header{$cluster_number};
		print CLUSTERCPU "$cluster_cpuline\n";
		close CLUSTERCPU;
		$cluster_cpu_header{$cluster_number} = 1;
	}
}
