#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';

#my $infile = $ARGV[0] or die "No file specified\n";
my @infiles = qw(
tx-app01.csv
tx-app02.csv
tx-app03.csv
tx-app05.csv
tx-app06.csv
tx-app07.csv
tx-app08.csv
tx-app09.csv
tx-app10.csv
tx-app13.csv
tx-app14.csv
tx-app21.csv
tx-app22.csv
tx-intprod01.csv
tx-intprod02.csv
tx-intprod03.csv
tx-intprod04.csv
);
#tx-ucm01.csv
#tx-ucm02.csv
#tx-ucm03.csv
#tx-ucm04.csv
#tx-ucm05.csv
#tx-ucm06.csv
#tx-websvc01.csv
#tx-websvc02.csv
#tx-websvc03.csv
#tx-websvc04.csv
#tx-websvc05.csv

# these hashes are needed in order to ensure columns are in the right order
my %mem;	# hash of hashes to hold memory values for all apps for all time points
		# $mem{timepoint}{app} = value
my %cpu;	# hash of hashes to hold cpu values for all apps for all time points
		# $cpu{timepoint}{app} = value
my %apps;	# hash that contains a list of apps that have run on a host
my %memheader;	# hash to know when to print header on app reports

for my $infile (@infiles) {
	my $lasttime = '';	# keep track of the last time slice seen so we know to wrap it up when we see a new time
	my $firstline = '';	# put header on first row of allmem and allcpu reports

	open F, $infile or die "Couldn't open $infile for read: $!\n";

	$infile =~ /(.+)\.csv/;
	my $host = $1;

	my $all_mem_report = "$host-mem.csv";
	my $all_cpu_report = "$host-cpu.csv";

#	open ALLMEM, ">> $all_mem_report" or die "Couldn't open $all_mem_report for write: $!\n";
#	open ALLCPU, ">> $all_cpu_report" or die "Couldn't open $all_cpu_report for write: $!\n";
	
	for my $line (<F>) {
		chomp $line;

		my ($time, undef, $app, $mem, $cpu) = split /,/, $line;

		if ( ( $lasttime eq '' ) || ( $lasttime eq $time ) ) {
			# if first line of the file or 
			# another entry with the same timestamp as last time

			my @args = ( $app, $mem, $cpu, $host, $time ); 
			&print_app_report( \@args );

			$lasttime = $time;
		}
		else {
			# first time we've seen time point
			# clear out variables
			$lasttime = $time;

			my @args = ( $app, $mem, $cpu, $host, $time ); 
			&print_app_report( \@args );
		}
	}

	my $header = 'Time';
	for my $app (sort keys %apps) {
		$header .= ",$app";
	}
#	print ALLMEM "$header\n";
#	print ALLCPU "$header\n";

	my $memline;
	for my $time (sort keys %mem) {
		$memline = $time;
		for my $app (sort keys %apps) {
			$mem{$time}->{$app} = 0 unless $mem{$time}->{$app};
			$memline .= ",$mem{$time}->{$app}";
		}
#		print ALLMEM "$memline\n";
	}

	my $cpuline;
	for my $time (sort keys %cpu) {
		$cpuline = $time;
		for my $app (sort keys %apps) {
			$cpu{$time}->{$app} = 0 unless $cpu{$time}->{$app};
			$cpuline .= ",$cpu{$time}->{$app}";
		}
#		print ALLCPU "$cpuline\n";
	}

#	close ALLMEM;
#	close ALLCPU;

	# clear this header flag hash
	for ( keys %memheader ) {
		delete $memheader{$_};
	}

	&cleanup();
}

sub print_app_report {
	my $ref = shift;
	my $app = ${$ref}[0];
	my $mem = ${$ref}[1];
	my $cpu = ${$ref}[2];
	my $host = ${$ref}[3];
	my $time = ${$ref}[4];
	
	$app =~ s/\//-/;
	$app = 'noname' unless $app;

	# if this is the first time this app has been seen,
	# write header
	unless ( $memheader{$app} ) {
		open F, "> $host-$app.csv" or die "Couldn't open $host-$app.csv for write: $!\n";
		print F "Time,Memory,CPU\n";
		close F;
	}

	open F, ">> $host-$app.csv" or die "Couldn't open $host-$app.csv for write: $!\n";
	print F "$time,$mem,$cpu\n";
	close F;

	$mem{$time}{$app} = $mem;
	$cpu{$time}{$app} = $cpu;
	$apps{$app}++;
	$memheader{$app} = 1;
}

sub cleanup {
	# clear these two globalhashes
	for ( keys %mem ) {
		delete $mem{$_};
	}
	
	for ( keys %cpu ) {
		delete $cpu{$_};
	}
	
	for ( keys %apps ) {
		delete $apps{$_};
	}
}
