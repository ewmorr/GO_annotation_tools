#!/usr/bin/perl
#Eric Morrison
#062017
#Usage: map_GO_ID_to_name.pl [go.obo] [anotations.gaf]
#This script uses a GO .obo file that contains definitions of GO terms and a .gaf format
#annotation file to map GO ID numbers to GO names. Output is six columns with the 
#accession number of the annotated gene/protein, GO ID, GO name, C/F/P to indicate 
#the parent term, def, and any comments. C = cellular_component; P = biological_process; F = molecular_function
#The expected format for OBO is 1.2, and for GAF is 2.0.

use strict;
use warnings;

my $obo = $ARGV[0];
my $gaf = $ARGV[1];

open(OBO, "$obo") || die "Can't open OBO file.\n";
open(GAF, "$gaf") || die "Can't open GAF file.\n";

chomp(my @obo = <OBO>);
chomp(my @gaf = <GAF>);


#process obo to terms
my $ob = join(">><<>><<", @obo);
my @ob = split(/>><<>><<\[\w+\]>><<>><</, $ob); #There are other instances of [\w+] that do not delimit entries

#hash indexed by GO ID, containing entries indexed by entry name
my %gos;
foreach my $gos (@ob)
	{
	if($gos !~ /^id: GO:\d+/){next;}
	
	my @gos = split(">><<>><<", $gos);
	#print $gos[0], "**\n";
	
	my @id = split(/: /, $gos[0]);
	shift@gos;#Remove ID to use as parent key for hash
	
	foreach my $go (@gos)
		{
		if($go eq ""){next;}
		
		my@go = split(/: /, $go);
		$gos{$id[1]}{$go[0]} = $go[1];
		#print $go[0], "\n";
		}
	}

#GAF hash; key is accesion; push GO ID to array
my %gaf;
my $gafcount;
foreach my $gf (@gaf)
	{
	$gafcount++;
	if($gf =~ /^!/){next;}
	my @gf = split("\t", $gf);
	
	if($gf[4] !~ /^GO:\d+/){print "GO ID in wrong column at line $gafcount\n";}
	else{push(@{$gaf{$gf[1]}}, $gf[4]);}
	}


my %nameSpace = (
	"cellular_component" => "C",
	"biological_process" => "P",
	"molecular_function" => "F");

foreach my $acc (sort {$a cmp $b} keys %gaf)
	{
	my %ids; #hash to store GO IDs per accession number
	my %child;#hash to reduce annotations based on names

#	print $acc, "\n"; #uncomment for testing
	foreach my $goID (@{ $gaf{$acc} } )
		{
		
		$ids{$acc}{$goID} = 1; #stores GO IDs per accession number as hash keys to compress redundant
		
		if($goID !~ /GO:0003674|GO:0008150|GO:0005575/)
			{
			$child{$acc}{ $nameSpace{ $gos{$goID}{'namespace'} } }++; #add count if value is other than root of ontology
			#print $names{$acc}{"child"}{ $names{$acc}{$goID}{'namespace'} }++, "\n";
			}
		}		
		
	foreach my $goID (sort {$a cmp $b } keys %{ $ids{$acc} } )
		{
		if($goID =~ /GO:0003674|GO:0008150|GO:0005575/ && #roots of ontology
		defined( $child{$acc}{ $nameSpace{ $gos{$goID}{'namespace'} } } ) == 1)#child is undefined if there are no children terms
			{
#			print "skip root\t$nameSpace{ $gos{$goID}{'namespace'} }\n"; #uncomment for testing
			next;
			}elsif($goID =~ /GO:0003674|GO:0008150|GO:0005575/)
			{
#			print "root\t$nameSpace{ $gos{$goID}{'namespace'} }\n"; #uncomment for testing
			
			print "$acc\t$goID\t$gos{$goID}{'name'}\t$nameSpace{ $gos{$goID}{'namespace'} }\t$gos{$goID}{'def'}\t";
			if( defined($gos{$goID}{'comment'} ) == 1)
				{
				print $gos{$goID}{'comment'}, "\n";
				}else{
				print "NA\n";
				}

			}else{
#			print $nameSpace{ $gos{$goID}{'namespace'} }, "\t", $child{$acc}{ $nameSpace{ $gos{$goID}{'namespace'} } }, "\n"; #uncomment for testing
			
			print "$acc\t$goID\t$gos{$goID}{'name'}\t$nameSpace{ $gos{$goID}{'namespace'} }\t$gos{$goID}{'def'}\t";
			if( defined($gos{$goID}{'comment'} ) == 1)
				{
				print $gos{$goID}{'comment'}, "\n";
				}else{
				print "NA\n";
				}
			}
		}

	}



