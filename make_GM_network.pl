#!/usr/bin/perl
use warnings;
use strict;

#store SNP-gene map
open FILE, $ARGV[0];
my $map;
while (<FILE>)
{
	chomp $_;
	my @line = split /\t/, $_;
	$map->{$line[2]}->{$line[3]} = 1;
}
close FILE;

#store pleio gene ids
open PLEIO, $ARGV[1];
my $pleio;
while (<PLEIO>)
{
	chomp $_;
	$pleio->{$_} = 1;
}
close PLEIO;

open OUT, ">$ARGV[3]";

open MOD, $ARGV[2];
my $done;
while (<MOD>)
{
	chomp $_;
	my @line = split /;/, $_;
	my $mod = $line[0];
	my @snps = split /\s+/, $line[1];
	for my $s (@snps)
	{
		for my $g (keys %{$map->{$s}}) #some snps are in multiple genes, some of which might not be pleio
		{
			if (defined $pleio->{$g})
			{
				if (not (defined $done->{$mod}->{$g}))
				{
					print OUT "$mod\thas_snp_in_gene\t$g\n";
					$done->{$mod}->{$g} = 1;
				}
			}
		}
	}
}
close MOD;
close OUT;
