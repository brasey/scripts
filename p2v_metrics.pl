#!/usr/bin/perl

use strict;
use warnings;

my %app;
my @top_output;
my $unknown_app_no = 1;
my $outfile = '/home/sarobot/p2vstats.csv';

chomp(my $date = `date +"%D %R"`);
my @ps_output = `ps -eo pid,cmd | grep java | grep -v grep`;

for my $line(@ps_output) {
	$line =~ s/^ +//;
        my @fields = split / +/, $line;

        my $pid = $fields[0];
        $line =~ /-DUNIQUE-ID=(\S+) /;

        my $app = $1;

	unless ($app) {
		# Some apps don't have UNIQUE-ID configured

		if ($line =~ /-Dcatalina.home=(\S+)\//) {
			# pull value from catalina.home
			# if it exists

			my $path = $1;
			$path =~ /\/export\/(\S+?)\//;
			$app = $1;
		}
		elsif ($line =~ /-Dlog.output.dir=(\S+)\//) {
			# otherwise
			# pull value from log.output.dir

			my $path = $1;
			$path =~ /\/export\/(\S+?)\//;
			$app = $1;
		}
		else {
			$app = 'unknown' . $unknown_app_no;
			$unknown_app_no++;
		}
	}
	
	if ($app =~ /^\d+$/) {
		# Some apps have UNIQUE-ID misconfigured
		# as a number

		$line =~ /-Dcatalina.home=(\S+)\//;
		# pull value from catalina.home

		my $path = $1;
		$path =~ /\/export\/(\S+?)\//;
		$app = $1;
	}

	if ($app =~ /^sharedtomcat-1-staging$/) {
		# Some apps have UNIQUE-ID misconfigured
		# as a staging holder name, and is duplicated

		$line =~ /-Dcatalina.home=(\S+)\//;
		# pull value from catalina.home
		# need to pull two dirs from path

		my $path = $1;
		$path =~ /\/export\/(\S+?\/\S+?)\//;
		$app = $1;
	}

	$app{$pid} = $app;
}

# top can only take 20 pids at a time
my $count = (keys %app);

if ($count <= 20) {
	my $pids = join(',',(keys %app));
	@top_output = `top -n1 -b -p $pids`;
	&print_report(\@top_output);
}
else {
	my @pids = (keys %app);

	while (@pids > 0) {
		my $counter = 1;
		my @twenty_pids;
		while ($counter <=20) {
			my $pid = shift @pids;
			$counter++;
			next unless $pid;

			push @twenty_pids, $pid;
		}
		my $pids = join(',',(@twenty_pids));
		@top_output = `top -n1 -b -p $pids`;
		&print_report(\@top_output);
	}
}


sub print_report {
	my @top_output = @{top_output};
	my $seen = 0;

	open OUTFILE, ">> $outfile" or die "Couldn't open outfile for write: $!\n";

	# output like this
	# time,pid,app,mem,cpu

	for my $line(@top_output) {
		if ($line =~ /COMMAND/) {
			$seen++;
			next;
		} 
		next unless $seen > 0;

		$line =~ s/^ +//;
		chomp $line;
		my @fields = split / +/, $line;
		my $pid = $fields[0];

		# sometimes pid populates with nothing
		next unless ($pid && $pid > 0);
		my $mem = $fields[5];
		if ($mem =~ s/m//) {
			$mem = $mem * 1024;
		}
		elsif ($mem =~ s/g//) {
			$mem = int($mem * 1024 * 1024);
		}
		my $cpu = $fields[8];
		
		print OUTFILE "$date,$pid,$app{$pid},$mem,$cpu\n";
		#print "$date,$pid,$app{$pid},$mem,$cpu\n";
	}

	close OUTFILE;
}
