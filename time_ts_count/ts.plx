#!/usr/bin/env perl
#

use warnings;
use v5.34;
use autodie;

use DateTime::Format::Strptime;

my $file = '/home/bo/scripts/time_ts_count/time.txt';
my (@ts, @start, @stop, $start, $stop, $fmt, $parser, $dt1, $dt2, $diff, $sumH, $sumM, $sum);

open my $IN, "<", $file;
while ( <$IN> ) {
  next unless $_ =~ /(\d{2}:\d{2})\s?-\s?(\d{2}:\d{2})\s?-/;
  push ( @ts, $_ );
}
close $IN;

foreach ( @ts ) {

  $_ =~ /(\d{2}:\d{2})\s?-\s?(\d{2}:\d{2})\s?-/;
  push @start, $1;
  push @stop, $2;
}

$fmt = '%H:%M';

while ( @start || @stop ) {

  $start = shift @start || "empty";
  $stop = shift @stop || "empty";

  $parser = DateTime::Format::Strptime->new(pattern => $fmt);

  $dt1 = $parser->parse_datetime($start) or die ($start);
  $dt2 = $parser->parse_datetime($stop) or die ($stop);

  $diff = $dt2 - $dt1;

  $sumH = $sumH + $diff->hours;
  $sumM = $sumM + $diff->minutes;
  #  print $diff->hours, " hours\n";
  #  print $diff->minutes, " minutes\n";


}

$sum = ( $sumH * 60 )+ $sumM;
say int($sum / 60);
