#!/usr/bin/perl

use strict;
use warnings;

my @pids;
my %app;
my %cmd;
my %java;
my %java_version;
my %connections;
my %memory;
my $unknown_app_no = 1;

my @results = `ps -eo pid,cmd | grep java | grep -v grep`;

for my $line(@results) {
	# Use ps to gather pids and commands with args

	$line =~ s/^ +//;
	my @fields = split / /, $line;

	my $pid = $fields[0];
	push @pids, $pid;

	my $java = $fields[1];
	$java =~ s/ //g;
	$java{$pid} = $java;

	if ($line =~ /-DUNIQUE-ID=(\S+) /) {
		my $app = $1;
		$app{$pid} = $app;
	}
	else {
		$app{$pid} = 'unknown' . $unknown_app_no;
		$unknown_app_no++;
	}

	$cmd{$pid} = $line;
}

for my $pid(keys %java) {
	# iterate through pids
	# populate %java with all gathered java binaries

	my $java = $java{$pid};
	$java_version{$java} = 1;
}

for my $binary(keys %java_version) {
	# iterate through java binaries
	# grab java version for each binary we've seen

	my $version = `$binary -version 2>&1`;
	$java_version{$binary} = $version;
}

my @netstat = `netstat -an --tcp`;

for my $line(@netstat) {
	# iterate through each line of netstat returned results
	# add unique connections on production network and loopback

	# skip text
	next if $line =~ /^\w{4,}/;

	# skip traffic on storage network
	next if $line =~ /10\.145\./;


	my @fields = split / +/, $line;
	my $local = $fields[3];
	my $remote = $fields[4];
	$connections{$local}++;
	$connections{$remote}++;
}

# Print everything

for my $pid(sort keys %app) {
	# iterate through pids
	# print application names

	print "$app{$pid}\n";
}

print "\n\n";

for my $binary(keys %java_version) {
	# iterate through java binaries

	for my $pid(sort keys %java) {
		if ($java{$pid} eq $binary) {
			print "$app{$pid}\n";
		}
	}
	print "$java_version{$binary}\n";
}

print "\n";

for my $ip_port(sort keys %connections) {
	# iterate through unique IP+ports
	# count connections, excluding certain ones

	my ($ip, $port) = split /:/, $ip_port;

	# don't count if port is over 10000
	next if $port > 10000;

	# don't count port 199 (it's an snmp thing)
	next if $port == 199;

	print "$connections{$ip_port} connections to $ip_port\n";
}

print "\n\n";
print "START       SIZE     RSS   DIRTY PERM MAPPING\n";

for my $pid(sort keys %app) {
	# iterate through pids
	# grab memory usage for java apps

	print "$app{$pid}\n";
	my $memory = `pmap $pid | grep Total:`;
	print "$memory\n";
}

for my $pid(sort keys %cmd) {
	# iterate through pids
	# print command with args

	my $command = $cmd{$pid};
	$command =~ s/ +/\n/g;
	print "$command\n";
}
