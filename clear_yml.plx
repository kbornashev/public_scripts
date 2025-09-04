#!/usr/bin/env perl
#

$file_path=shift;

open $READ, $file_path;

while(<$READ>){

  $_ =~ s/\s*$//g;
  $_ =~ s/^\s+$//g;

  print "$_\n";

  push(@array, $_);
}

close $READ;

open $WRITE, ">", $file_path;

foreach(@array){
  print $WRITE $_;
}

close $WRITE;


