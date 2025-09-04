#!/usr/bin/env perl

use warnings;
use 5.34.0;
use autodie;
use Cwd qw(cwd getcwd);

my $file = getcwd;

opendir(FL, $file) || die "Cant open #file: $!";
while (readdir FL) {
				next if $_ =~ /^\./ ;
				print "$_\n";
}
close FL;
