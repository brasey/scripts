#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';

my @files = <*.csv>;

my %max;	# Hash holds max memory value for each app
my %min;	# Hash holds min memory value for each app
my %values;	# Hash of arrays holds all memory values for each app
my %mean;	# Hash holds mean memory value for each app
my %median;	# Hash holds median memory value for each app

for my $file (@files) {
	my $line_no;	# Count lines
	
	$file =~ /(.+)\.csv/;
	my $app = $1;

	open F, $file or die "Couldn't open $file for read: $!\n";

	for my $line (<F>) {
		$line_no++;
		next if $line_no == 1;		# Discard header

		$line =~ /.*?,(.+?),/;
		my $value = $1;

		push @{ $values{$app} }, $value;

		if ($line_no == 2) {
			$max{$app} = $value;
			$min{$app} = $value;
		}
		else {
			$min{$app} = $value if $value < $min{$app};
			$max{$app} = $value if $value > $max{$app};
		}
	}
	close F;
}

for my $app (sort keys %values) {
	my $total = 0;
	my $count = 0;
	my @sorted_values;

	for my $value ( sort( @{ $values{$app} } ) ) {
		$total += $value;
		$count++;
		push @sorted_values, $value;
	}

	$mean{$app} = int( $total / $count );
}

print "app,min,max,average\n";
for my $app (sort keys %max) {
	print "$app,$min{$app},$max{$app},$mean{$app}\n";
}
