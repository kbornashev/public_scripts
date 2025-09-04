#!/usr/lib/env perl

use warnings;
use v5.34;
use autodie;

my $file = '/home/bo/.ssh/config';

open my $IN, ">>", $file;

print "SSH ";

print "Host (alias): ";
my $host = <STDIN> ;
print $IN "Host $host";

print "HostName (IP): ";
my $hostname = <STDIN>;
print $IN "\tHostName $hostname";

print "User: (username) ";
my $username = <STDIN>;
print $IN "\tUser $username";

close $IN;
