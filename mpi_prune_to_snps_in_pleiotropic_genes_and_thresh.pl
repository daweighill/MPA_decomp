#!/usr/bin/perl
use warnings;
use strict;
use Parallel::MPI::Simple;


MPI_Init();  # initialize MPI thing
my $rank = MPI_Comm_rank(MPI_COMM_WORLD); # get rank of current job
my $numjobs = MPI_Comm_size(MPI_COMM_WORLD) - 1;


#list of PS index result files
my $in = $ARGV[0];

if ($rank == 0) # master job
{
	my $counter = 1;
	
	open FILES, $in;
	while (<FILES>)
	{
		chomp $_;
		MPI_Send($_, $counter, 0, MPI_COMM_WORLD);
		$counter++;
	}
	close FILES;

}

else
{

	my $infile = MPI_Recv(0, 0, MPI_COMM_WORLD);
	my $file = $infile;
	my @list = split /\./, $infile;
	my $out = "$list[0]_pleiotropic.txt";
	
	my $ref;
	#open list of SNPs that reside in MPA genes
	open LIST, $ARGV[0];
	while (<LIST>)
	{
		chomp $_;
		$ref->{$_} = 1;
	}
	close LIST;

	open IN, $file;
	open OUT, ">$out";
	while (<IN>)
	{
		chomp $_;
		my @line = split /\t/, $_;	
		if ((defined $ref->{$line[0]}) and (defined $ref->{$line[2]}) and ($line[1] == 1))
		{
			print OUT "$_\n";
		}
	}
	close IN;
	close OUT;

}

MPI_Finalize();

