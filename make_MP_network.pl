#!/usr/bin/perl
use warnings;
use strict;

#store snp to phenotype in slef-loops file
open SL, $ARGV[0];
my $sl;
while (<SL>)
{
	chomp $_;
	my @line = split /\t/, $_;
	my @list = split /;/, $line[3];
	my $last = scalar(@list) - 1;
	for my $i (1..$last)
	{
		#sl->{snp}->{phenotype} = 1
		$sl->{$line[0]}->{$list[$i]} = 1;		
	}
}
close SL;

#open output MP network file
open OUT, ">$ARGV[2]";
my $done;

#open modules file
open MOD, $ARGV[1];
while (<MOD>)
{
	chomp $_;
	my @line = split /;/, $_;
	my $mod = $line[0];
	my @snps = split /\s+/, $line[1];
	my $arb_snp = $snps[0];
	for my $p (keys %{$sl->{$arb_snp}})
	{
		print OUT "$mod\thas_snp_assocaited_with\t$p\n";
	}
}
close MOD;
close OUT;
