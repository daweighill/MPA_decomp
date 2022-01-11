#!/usr/bin/perl
use warnings;
use strict;


#number of PS indices to be calculated per job
my $jobsize = $ARGV[1];

#read in GWAS profile matrix and get number of lines
my $matrix = "$ARGV[0]"; 

#indices
my $jobid = 1; #index of the job
my $counter = 0; #to leave out first heading line
my $numcomp = 0; #to keep track of number of computations per job

#inital job start and end points
my $start = 0;
my $end = 0;


#get number of DATA lines in matrix (excluding headings)
my $wc = `wc -l $matrix`;
my @wclist = split /\s+/, $wc;
my $numlines = $wclist[0] - 1;

#open job index file
open INDEX, ">job_index.txt";
open FILE, $matrix;
while (<FILE>)
{
	chomp $_;
	my @line = split /\t/, $_;

	if ($counter != 0)
	{
	
		#get number computations for that SNP against others (in uper triangular matrix)
		my $comp = $numlines - $counter;
		
		#add this to comp counter for this job
		$numcomp += $comp;

		#if we have reached the approximate job size
		if ($numcomp >= $jobsize)
                {
			#get the start and end points for this job
			$start = $end + 1;
			$end = $counter;
			#print them to the index
			print INDEX "$jobid\t$start\t$end\n";
			
			#reset the computation counter and increase the job index for the next job
			$jobid++;
			$numcomp = 0;
		}
	}
	$counter++;
}
close FILE;

#if the last "end" value we have seen is not the last line in the file, print out the lst job start and end
if ($end != $numlines)
{
        my $laststart = $end + 1;
        my $lastend = $numlines;
        print INDEX "$jobid\t$laststart\t$lastend\n";
}
	
close INDEX;

