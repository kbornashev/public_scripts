#!/usr/bin/env perl
#

use warnings;
use v5.34;
use Switch;

my $green_zone = shift(@ARGV);
chomp ($green_zone);

my $memory = $green_zone * 3;

my $maxSysMem = 1024 * 1024 * 1024 * 16;
my $sysMem = $memory * 0.25;

sub get_green {

	if ( $sysMem > $maxSysMem ) {

					$sysMem = $maxSysMem ;
	}
	
	my $zone = ( $memory - $sysMem ) / 2;
	$zone = sprintf("%.2f", $zone);
	say "zone $zone";
	return $zone;
}

print $green_zone;
	
