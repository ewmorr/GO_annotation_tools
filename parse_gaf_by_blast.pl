#!/bin/perl
#Eric Morrison
#061917
#Usage: parse_gaf_by_blast.pl [gaf] [blast file(s)] 
#This script parses a gaf file by the accession numbers of blast hits (one hit per entry). Multiple blast files can be entered and the results of all hits will be used to create a single parsed file. Used to parse uniprot_goa_all.gaf by blast hits against uniprot reviewed protein db.
#


use strict;
use warnings;

my $gaf = $ARGV[0];
shift@ARGV;
my @blast = @ARGV;
#open(BLS, "$blast") || die "Can't open blast\n";
#chomp(my @blast=<BLS>);

#Process all blast results to hash to avoid repeat gaf entries
#i.e. one entry per blast hit
my %bls;
foreach my $blast (@blast)
	{
	
	open(BLS, "$blast") || die "Can't open blast file.\n";
	chomp(my @blast = <BLS>);
	#print $blast, "\n";
	foreach my $bls (@blast)
		{
		my @bls = split("\t", $bls);
		my @id = split(/\|/, $bls[1]);
		#print $id[1], "\n";
		$bls{$id[1]} = [@id];
		}
	}

#print scalar@blast, "\n";
open(GAF, "$gaf") || die "Can't open gaf file.\n";
#chomp(my @gaf = <GAF>);

#process gaf
my %gaf;
#foreach my $gf (@gaf)
while(my $gf = <GAF>)
	{
	chomp $gf;
	if($gf =~ /^!.*/){print $gf, "\n"; next;}
	my @gf = split("\t", $gf);
	#Need hash of hashes because Uniprot accessions have multiple GO entries. Go entries may not be unique unless in combination with GO_REF (column 5)
	$gaf{$gf[1]}{$gf[3].$gf[4]} = $gf;
	}

#print matches
foreach my $id (keys %bls)
	{
	foreach my $gf (keys %{ $gaf{$id} })
		{
		print $gaf{$id}{$gf}, "\n";
		}
	}

