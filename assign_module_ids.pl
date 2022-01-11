#!/usr/bin/perl
use warnings;
use strict;

open FILE, $ARGV[0];
open OUT, ">$ARGV[1]";

my $counter = 1;
while (<FILE>)
{
	print OUT "module$counter;$_";
	$counter++;
}
close FILE;
close OUT;
