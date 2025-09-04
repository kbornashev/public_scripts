#!/usr/bin/env perl

use warnings;
use v5.34.0;

my $file = shift;
my $string;
my @array;

open(FILE, '<', $file) or die $!;

while(<FILE>){
				$_ =~ /^(?<link>https.*?\/(?<topic>\d{4,7})\/)\s(?<comment>.*)$/;
				my $link = $+{link};
				my $topic = $+{topic};
				my $comment =  $+{comment};
				$string = "[$topic $comment]($link)";
				push (@array, $string);
}

close(FILE);

foreach (@array) {
				say $_;
}
