#!/usr/bin/perl
use warnings;
use strict;
use Parallel::MPI::Simple;

#read in file
my $matrix = $ARGV[0];


#get number of DATA lines in file (this is also the index of the last data line)
my $wc = `wc -l $matrix`;
my @wclist = split /\s+/, $wc;
my $numlines = $wclist[0] - 1;


my $length;

#store matrix in list and store phenotype heading positions
my $metab_ref;
my $index = 0;
my @file = ();
open MAT, $matrix;
while (<MAT>)
{
	chomp $_;
	if ($index == 0)
	{
		my @line = split /\t/, $_;
		$length = scalar(@line) - 1;
		for my $j (1..$length)
		{
			$metab_ref->{$j} = $line[$j];
		}
	}
	push @file, $_;
	$index++;
}
close MAT;


MPI_Init();  
my $rank = MPI_Comm_rank(MPI_COMM_WORLD); # get rank of current job
my $numjobs = MPI_Comm_size(MPI_COMM_WORLD) - 1;

if ($rank == 0) # master job
{
	#open the index for the job
	open INDEX, "job_index.txt";
	while (<INDEX>)
        {
			#get start and end for the jobid and send those out to jobs
			chomp $_;
			my @line = split /\t/, $_;
			my $jobid = $line[0];
			my $start = $line[1];
			my $end = $line[2];
			my $parameters;	
			$parameters->{1} = $start;
			$parameters->{2} = $end;
			MPI_Send($parameters, $jobid, 0, MPI_COMM_WORLD);
	}
		
	close INDEX;
}

else #spawn job
{
	my $parameters = MPI_Recv(0, 0, MPI_COMM_WORLD);
	my $bottom = $parameters->{1};
	my $top = $parameters->{2};

	#make results directory
	`mkdir sif_files`;
	my $path = "sif_files/";
	my $out = "$path"."czek_gwas_profile"."_$rank.sif";
	open OUT, ">$out";
	
	for my $i ($bottom..$top)
	{
		my @line1 = split /\t/, $file[$i];
		my $index = $i + 1;
		for my $j ($index..$numlines)
		{
			my @line2 = split /\t/, $file[$j];
					
			my $var1 = $line1[0];
			my $var2 = $line2[0];

			my $topsum = 0;
			my $bottomsum = 0;

			my $contributing_phenotypes = "contributing_phenotypes";
			for my $k (1..$length)
			{
				#get phenotypes contributing to PSI (czekanowski)
				if (($line1[$k] > 0) and ($line2[$k] > 0))
				{
					my $phen = $metab_ref->{$k};
					$contributing_phenotypes = $contributing_phenotypes.";$phen";
				}
				
				if ($line1[$k] > $line2[$k])
				{
					$topsum = $topsum + $line2[$k];
				}

				else
				{
					$topsum = $topsum + $line1[$k];
				}
						
				$bottomsum = $bottomsum + $line1[$k] + $line2[$k];
			}
			
			
			my $czekanowski = (2 * $topsum) / $bottomsum;
			if ($czekanowski > 0)
			{		
				print OUT "$var1\t$czekanowski\t$var2\t$contributing_phenotypes\n";
			}
		}
	}
	close OUT;
}
MPI_Finalize();




