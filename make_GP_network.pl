#!/usr/bin/perl
use warnings;
use warnings;

#open list of MPA genes
open PLEI, $ARGV[0];
my $pleio_genes;

while (<PLEI>)
{
	chomp $_;
	my @line = split /\t/, $_;
	$pleio_genes->{$line[0]} = 1;
}
close PLEI;

#open GWAS results file
#column order: 
#phenotypeID	Pvalue	snpID	GeneID	PhenotypeAnnotation	BetaValue
open GWAS, $ARGV[1];

#open output GP network SIF file
open OUT, ">$ARGV[2]";

my $done;
while (<GWAS>)
{
	chomp $_;
	my @line = split /\t/, $_;
	if (defined $pleio_genes->{$line[3]})
	{
		if (not (defined $done->{$line[0]}->{$line[3]}))
		{
			print OUT "$line[0]\t$line[1]\t$line[3]\n";
			$done->{$line[0]}->{$line[3]} = 1;
		}
	}
}
close GWAS;
close OUT;
