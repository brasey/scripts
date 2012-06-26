#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';

my @infiles = qw(
tx-websvc01.csv
tx-websvc02.csv
tx-websvc03.csv
tx-websvc04.csv
tx-websvc05.csv
);

my %app_pool;

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
	my $host = $1;

	for my $line (<F>) {
		chomp $line;

		my ($time, undef, $app, $mem, $cpu) = split /,/, $line;

		if ($app =~ /(.+)\/\d/) {
			$app_pool{$1}++;
		}
		else {
			$app_pool{$app}++;
		}

		$app .= "-$host";

		$mem{$time}{$app} = $mem;
		$cpu{$time}{$app} = $cpu;
		$apps{$app}++;
	}
}

open CPU, "> allcpu.csv" or die "Couldn't open allcpu.csv for write: $!\n";
open MEM, "> allmem.csv" or die "Couldn't open allmem.csv for write: $!\n";

my $header = 'Time';
for my $app (sort keys %apps) {
	$header .= ",$app";
}
print CPU "$header\n";
print MEM "$header\n";

my %app_pool_mem_header;	# Know when to print the memory header for each app pool

for my $time (sort keys %mem) {
	my $memline = $time;
	for my $app (sort keys %apps) {
		$mem{$time}->{$app} = 0 unless $mem{$time}->{$app};
		$memline .= ",$mem{$time}->{$app}";
	}
	print MEM "$memline\n";

	for my $app_pool (sort keys %app_pool) {
		$header = 'Time';
		my $app_pool_memline = $time;

		for my $app (sort keys %apps) {
			next unless $app =~ /^$app_pool/;
			$header .= ",$app" unless $app_pool_mem_header{$app_pool};
			$app_pool_memline .= ",$mem{$time}->{$app}";
		}

		my $appmem_file = $app_pool . "-mem.csv";
		open APPMEM, ">> $appmem_file" or die "Couldn't open $appmem_file for append: $!\n";
		print APPMEM "$header\n" unless $app_pool_mem_header{$app_pool};
		print APPMEM "$app_pool_memline\n";
		close APPMEM;
		$app_pool_mem_header{$app_pool} = 1;
	}
}

my %app_pool_cpu_header;	# Know when to print the cpu header for each app pool

for my $time (sort keys %cpu) {
	my $cpuline = $time;
	for my $app (sort keys %apps) {
		$cpu{$time}->{$app} = 0 unless $cpu{$time}->{$app};
		$cpuline .= ",$cpu{$time}->{$app}";
	}
	print CPU "$cpuline\n";

	for my $app_pool (sort keys %app_pool) {
		$header = 'Time';
		my $app_pool_cpuline = $time;

		for my $app (sort keys %apps) {
			next unless $app =~ /^$app_pool/;
			$header .= ",$app" unless $app_pool_cpu_header{$app_pool};
			$app_pool_cpuline .= ",$cpu{$time}->{$app}";
		}

		my $appcpu_file = $app_pool . "-cpu.csv";
		open APPCPU, ">> $appcpu_file" or die "Couldn't open $appcpu_file for append: $!\n";
		print APPCPU "$header\n" unless $app_pool_cpu_header{$app_pool};
		print APPCPU "$app_pool_cpuline\n";
		close APPCPU;
		$app_pool_cpu_header{$app_pool} = 1;
	}
}

close CPU;
close MEM;
