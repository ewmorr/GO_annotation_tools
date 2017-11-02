#!/usr/bin/perl
#Eric Morrison
#072917
#sum_and_count_annotations.pl
#This script takes an annotation file with GO annotations and gene coverage as input and
#returns the total sum of genes for each GO name (including coverage), and the number of 
#genes for each go name. Sum is based on copy number calculated by gene coverage divided
#by median genome coverage.

use strict;
use warnings;

my $in = $ARGV[0];
open(IN, "$in") || die "Can't open input\n";

chomp(my @in = <IN>);

my$inn = join("\n", @in);
$inn =~ s/\r\n|\r|\n/\n/g;
@in = split("\n", $inn);




shift@in;
print "GOID	sum_copies	num_genes	UniprotKB	GOName	aspect\n";
my %ann;
#print scalar@in, "\n";

my$count;
foreach my $ann (@in)
	{
	my @ann = split("\t", $ann);
	$ann{$ann[7]}{'sum'} += $ann[4];
	$ann{$ann[7]}{'count'}++;
	$ann{$ann[7]}{'UniprotKB'} = $ann[6];
	$ann{$ann[7]}{'name'} = $ann[8];
	$ann{$ann[7]}{'aspect'} = $ann[9];
	
	#$count++;
	#print $count, "\t", $ann[9], "\n";

	}

foreach my $id (sort{$a cmp $b} keys %ann)
	{
	print "$id\t$ann{$id}{'sum'}\t$ann{$id}{'count'}\t$ann{$id}{'UniprotKB'}\t$ann{$id}{'name'}\t$ann{$id}{'aspect'}\n";
	}
