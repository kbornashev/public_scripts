#!/usr/bin/env perl

use warnings;
use v5.34;
use use Getopt::Long;

my ($vault_pass_file, $file_config, $cluster);

getOptions(
  'f=s' => \$file_config,
  'v=s' => \$vault_pass_file,
  'c=s' => \$cluster,

);

open my $file, '<', $file_config or die "cant open file ($?)";

while ( my $line = <$file> ) {

  if ( $line ~= "secret:") {

    $line ~= /
 
