#!/usr/bin/env perl
use strict;
use warnings;
my $nickname = shift or die "Usage: $0 <nickname>\n";
my $keys_file = '/home/bo/om/ssh_keys.txt';
open my $fh, '<', $keys_file or die "Cannot open file '$keys_file' $!";
while (my $line = <$fh>) {
    chomp $line;
    
    if ($line =~ /^#\s*$nickname\s*$/) {
        my $ssh_key = <$fh>;
        chomp $ssh_key;
        
        print "$ssh_key";
        
        last;
    }
}
close $fh;
