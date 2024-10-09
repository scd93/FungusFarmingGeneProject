library(tidyverse)
library(rentrez)
library(phylotools)
library(googlesheets4)
library(rBLAST)
library(splitstackshape)
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "/programs/ncbi-blast-2.10.1/bin/", sep= .Platform$path.sep))

GeneInfo <- read_sheet("https://docs.google.com/spreadsheets/d/1DySMVPuDZMm3t5AzumYd9LzMyeJ9pSnt8n-X2VAqVDk/edit?usp=sharing")
TestGeneID <- "105201597"

#create CandidateGenes subdirectory
dir.create("CandidateGenes")

#make DownloadCandidateGenes function, uses locus number to look in gene database for corresponding protein ID
DownloadCandidateGenes <- function(LocusNumber) {
  GeneToProtein <- entrez_link(dbfrom = "gene", 
                               id = LocusNumber,
                               db = "protein")
#extract ProteinID
  GeneToProtein[["links"]][["gene_protein_refseq"]][[1]]
  ProteinID <- GeneToProtein[["links"]][["gene_protein_refseq"]][[1]]
  
#Name file with LocusNumber as a fasta under ./CandidateGenes path to subdirectory
  ExportFilename <- paste("./CandidateGenes/",
                          LocusNumber, 
                          ".fasta",
                          sep = "")
#Download protein sequence in fasta format  
  entrez_fetch(db="protein",
               id = ProteinID,
               rettype = "fasta") %>% 
    write(file = ExportFilename)
}

#Send error message instead of stopping download for NA rows 
PossiblyDownloadCandidateGenes <- possibly(DownloadCandidateGenes, otherwise = "error")

#Loop over Gene ID column of GeneInfo dataframe to download all specific candidate genes 
map(GeneInfo$`Gene ID`, PossiblyDownloadCandidateGenes)

#Make a list of genomes as AA sequences that are within the OrthoFinder folder
ListOfGenomes <- list.files(path = "./03_TranslatedGenomesOrthoFinder", 
                            pattern = "*_Proteins.fasta", 
                            full.names = TRUE)

if (file.exists("ListOfGenomesAASequences.fasta")) {
  cat("The file is there", "\n")
} else {
  ListOfGenomes <- list.files(path = "./03_TranslatedGenomesOrthoFinder",
                              pattern = "*_Proteins.fasta", full.names = TRUE)
  
  ListOfAAGenomes <- map(ListOfGenomes, read.fasta)
  ListOfAAGenomes <- as.data.frame(do.call(rbind, ListOfAAGenomes))
  
  dat2fasta(ListOfAAGenomes, outfile = "ListOfGenomesAASequences.fasta")
  
}
#Make the database for blast
makeblastdb(file = "ListOfGenomesAASequences.fasta", dbtype = "prot")

#Store a search that will be used for blast (p for protein sequences)
blastsearch <- blast(db = "ListOfGenomesAASequences.fasta", type = "blastp")

#make blastcandidategene function that will be run over candidate gene list
blastCandidateGene <- function(CandidateGeneFile) {
  querysequence <- readAAStringSet(CandidateGeneFile, format = "fasta")
  #run blast and store results in blastresults
  blastresults <- predict(blastsearch, querysequence, BLAST_args = "-max_target_seqs 1")
  return(blastresults)
}

#make a list of candidate genes for blast
ListCandidateGenes <- list.files(path = "./CandidateGenes/", full.names = TRUE)

#prevent loop from stopping at error
PossiblyBlastCandidateGene <- possibly(blastCandidateGene, otherwise = "error")

#Loop over ListCandidateGenes to blast all specific candidate genes and store in CandidateGeneBlastResults
CandidateGeneBlastResults <- map(ListCandidateGenes, PossiblyBlastCandidateGene)

#Create a data frame (more accessible)
CandidateGeneBlastResults <- as.data.frame(do.call(rbind, CandidateGeneBlastResults))

#Read in Orthogroups.tsv
OrthoGroupInformation <- read_delim(file = "./03_TranslatedGenomesOrthoFinder/OrthoFinder/Results_May31/Phylogenetic_Hierarchical_Orthogroups/N0.tsv", 
                                    delim = "\t")
OrthoGroupInformation <- OrthoGroupInformation %>% select(-c("OG", "Gene Tree Parent Clade"))

OrthoGroupInformation <- OrthoGroupInformation %>% pivot_longer(cols = -c(HOG),
                                                                names_to = "junk") %>% 
  distinct()

OrthoGroupInformation <- concat.split.multiple(OrthoGroupInformation, split.cols = "value", seps = "," , direction = "long" )

CandidateGenes_Orthogroups <- left_join(CandidateGeneBlastResults, OrthoGroupInformation, by= c("sseqid"="value"))
