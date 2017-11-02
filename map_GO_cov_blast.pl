#!/usr/bin/perl
#Eric Morrison
#062317
#Usage: map_GO_cov_blast.pl [reference go names] [gene coverage file] [blast results] [optional list of sequence ids to include]
#This script combines uses a file of GO names produced by map_GO_ID_to_name_and_reduce.pl,
#the result of get_maker_mRNA_coverage.pl, and a file of blast results (-outfmt 6), to 
#produce a new file with gene ID, GO names/IDs, and coverage estimated by three methods
#(gene covertage divided by mean/median/mode genome coverage). A file of sequence ids 
#(one per line) can optionally be provided. If provided only these will be included in the output.

use strict;
use warnings;

my $goNames = $ARGV[0];
my $geneCov = $ARGV[1];
my $blastFile = $ARGV[2];
my %ids;
if(defined($ARGV[3]) == 1)
	{
	my $ids = $ARGV[3];
	open(IDS, "$ids") || die "Can't oepn list of ids\n";
	chomp(my@ids = <IDS>);
	foreach my $id (@ids)
		{
		$ids{$id} = 1;
		}
	}
		

open(GO, "$goNames") || die "Can't open go names\n";
open(COV, "$geneCov") || die "Can't open coverage file\n";
open(BLS, "$blastFile") || die "Can't open blast file\n";

my %gos;
while(my $gos = <GO>)
	{
	chomp$gos;
	my@gos = split("\t", $gos);
	$gos{$gos[0]}{$gos[1]} = $gos;
	}
my %cov;
while(my $cov = <COV>)
	{
	chomp$cov;
	if($cov =~ /^#/)
		{
		next;
		}
	my@cov = split("\t", $cov);
	$cov{$cov[1]} = [ @cov ];
	}
	
chomp(my @blast = <BLS>);
print "#seqID.ann.#\tseqID\tcoverage\tcopy_num.mean\tcopy_num.median\tcopy_num.mode\tUniprotKB\tGOID\tGOName\taspect\tGOdef\tGOcomment\n";
foreach my $bls (@blast)
	{
	my @bls = split("\t", $bls);
	my $genID = $bls[0];
	if(scalar keys(%ids) >= 1 && defined($ids{$genID}) != 1)
		{
		next;
		}
	my @acc = split(/\|/, $bls[1]);
	my $acc = $acc[1];
	
	my $count = 0;
	foreach my $goID (keys %{ $gos{$acc} } )
		{
		#print STDERR "$bls[0]\n";
		print "$bls[0].ann.$count\t$bls[0]\t",
			sprintf("%.2f", $cov{$genID}[2]), "\t", 
			sprintf("%.0f", $cov{$genID}[3]), "\t", 
			sprintf("%.0f", $cov{$genID}[4]), "\t",
			sprintf("%.0f", $cov{$genID}[5]), "\t",
			$gos{$acc}{$goID}, "\n";
		$count++;
		}
	}





