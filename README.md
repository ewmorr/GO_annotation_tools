This workflow uses blast matches for proteins from individual genomes against the Uniprot-Swissprot protein database to assign GO terms. These GO terms are then mapped to a set of GO "slim" terms to map to higher level functional categories. The result is a single file in GAF format that contains gene annotations for every Uniprot accession that was hit by a protein in the original blast queries, and which can then be used to annotate individual proteins, generate copy number of genes within categories, and sum total gene copies and number of genes within a category.


##### Workflow

Parse GO gene annotation file (.gaf) by blast hits. The most efficienct workflow is to input all blast files of interest for a given dataset so that the complete GAF must only be parsed once. Blast file format is expected to be `-outfmt 6`. Multiple blast files entered comma-separated.
Parsing the GAF to retain only relevant annotations reduces run time for slim mapping with owltools.
Read me for GAF from GO ( http://www.geneontology.org/gene-associations/readme/goa.README )

```
parse_gaf_by_blast.pl goa_uniprot_all.gaf [blast files] > goa_uniprot_all.blast_matches.gaf
```

Map slim terms using owltools ( https://github.com/owlcollab/owltools )
The option `--idfile` is used to map to a customized list of slim terms. The slim terms are a list of GO IDs (e.g. GO:0003674) one per line. The `--idfile` option can be replaced with `--subset` to use a predefined slim (e.g. `--subset goslim_aspergillus`) ( http://www.geneontology.org/page/go-slim-and-subset-guide, http://geneontology.org/page/download-ontology)

```
owltools go-basic.obo --gaf goa_uniprot_all.blast_matches.gaf --map2slim --idfile slim_terms.txt --write-gaf goa_uniprot_all.blast_matches.slim.gaf
```

Map GO IDs to names of GO categories. A single protein can have multiple matches to a single "slimmed" GO category. This is because a protein can match multiple granular GO terms, and mapping these can result in multiple matches to the same slim term. This script reports only one such instance rather than all redundant cases.
This example uses the go-basic.obo and is reccomended for use with custom slim. Alternatively a custom OBO file could be created, or an OBO associated with a specific slim map (e.g. aspergillus_slim.obo).

```
map_GO_ID_to_name_and_reduce.pl go-basic.obo goa_uniprot_all.blast_matches.slim.gaf > goa_uniprot_all.blast_matches.names_reduced.txt
```

Map proteins from individual genomes to the slim annotation file and combine with coverage information. Uses a file of GO names produced by [map_GO_ID_to_name_and_reduce.pl](map_GO_ID_to_name_and_reduce.pl), the result of [get_maker_mRNA_coverage.pl](get_maker_mRNA_coverage.pl), and a file of blast results (-outfmt 6), to produce a new file with gene ID, GO names/IDs, and coverage estimated by three methods (gene coverage divided by mean/median/mode genome coverage). A file of sequence ids (one per line) can optionally be provided. If provided only these will be included in the output.
This file can be imported to R for analyses by setting "\t" as the delimiter in read.table()

```
map_GO_cov_blast.pl goa_uniprot_all.blast_matches.names_reduced.txt [coverage file for proteins] [blast results for proteins] [optional ids list] > annotated_proteins_for_genome.txt
```

Sum the total copy numbers using estimate based on median genome coverage, and total number of genes within each GO slim category within the genome. These can be used along with the total number of predicted proteins to assess percentage of proteins within a particular GO category. 

```
sum_and_count_annotations.pl annotated_proteins_for_genome.txt > annotated_proteins_for_genome.summed.txt
```
