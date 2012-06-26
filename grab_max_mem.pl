#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';

my @files = <*.csv>;

my %max;	# Hash holds max memory value for any given app

for my $file (@files) {
	my $line_no;	# Count lines
	
	$file =~ /(.+)-mem\.csv/;
	my $app = $1;

	open F, $file or die "Couldn't open $file for read: $!\n";

	for my $line (<F>) {
		chomp $line;
		$line_no++;
		next if $line_no == 1;		# Discard header
		my @values = split /,/,$line;
		shift @values;			# Discard date/time
		for my $value (@values) {
			#print "$max{$app}\t$value\n";
			$max{$app} = $value if $value > $max{$app};
		}
	}
	close F;
}

for my $app (sort keys %max) {
	print "$app,$max{$app}\n";
}
