library(tidyverse)
library(rentrez)
library(phylotools)
library(googlesheets4)
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

#Send error message instead of stopping download for NA rows 
PossiblyDownloadCandidateGenes <- possibly(DownloadCandidateGenes, otherwise = "error")

#Loop over Gene ID column of GeneInfo dataframe to download all specific candidate genes 
map(GeneInfo$`Gene ID`, PossiblyDownloadCandidateGenes)

#Make a list of genomes as AA sequences that are within the OrthoFinder folder
ListOfGenomes <- list.files(path = "./03_TranslatedGenomesOrthoFinder", pattern = "*_Proteins.fasta", full.names = TRUE)

if (file.exists("ListOfGenomesAASequences.fasta")) {
  cat("The file is there", "\n")
} else {
  ListOfGenomes <- list.files(path = "./03_TranslatedGenomesOrthoFinder", pattern = "*_Proteins.fasta", full.names = TRUE)
  
  ListOfAAGenomes <- map(ListOfGenomes, read.fasta)
  ListOfAAGenomes <- as.data.frame(do.call(rbind, ListOfAAGenomes))
  
  dat2fasta(ListOfAAGenomes, outfile = "ListOfGenomesAASequences.fasta")
  
}





