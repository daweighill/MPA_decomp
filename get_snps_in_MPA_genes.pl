#!/usr/bin/perl
use warnings;
use strict;


#snp to gene map
open MAP, $ARGV[0];
my $map;
my $snp_gwas;
my $gene_gwas;
while (<MAP>)
{
        chomp $_;
        my @line = split /\t/, $_;
	#map->{snp}->{gene} = 1
        $map->{$line[2]}->{$line[3]} = 1;
	#snp_gwas->{snp}->{phenotype} = 1;
	$snp_gwas->{$line[2]}->{$line[0]} = 1;
	#gene_gwas->{gene}->{phenotype} = 1;
	$gene_gwas->{$line[3]}->{$line[0]} = 1;
}
close MAP;



#list of snps in MPA genes
open OUT, ">$ARGV[1]";

#self loops of snps in MPA genes
open OUT2, ">$ARGV[2]";


my $doneSL;
my $donesnp;
#loop through snps in genes
for my $s (keys %{$map}) #s is snp
{
       #for each gene snp is in
       for my $g (keys %{$map->{$s}}) #g is gene
       {
                #get num phenotypes gene is assocaited with
                my @hits = keys %{$gene_gwas->{$g}};
                my $num_hits = scalar(@hits);
                if ($num_hits >= 2)
                {
			if (not (defined $donesnp->{$s}))
			{	
				print OUT "$s\n";
				$donesnp->{$s} = 1;
			}
	
			my $string = "contributing_phenotypes";
			for my $p (keys %{$snp_gwas->{$s}})
			{
				$string = $string.";$p";
			}
			if (not (defined $doneSL->{$s}))
			{
				print OUT2 "$s\t1\t$s\t$string\n";
				$doneSL->{$s} = 1;
			}       
       		  }
		else
		{
			#print "$i\t$num_hits\n";	
		}
        }

}
close OUT;
close OUT2;
