library(phylotools)
library(seqinr)
library(tidyverse)

GenomeFiles <- list.files(path = "./", 
                          pattern = "*.fna",
                          all.files = FALSE,
                          full.names = TRUE)
TranslatingGenomes <- function(inputfile) {
  SpeciesCode <- str_split_i(inputfile, "_", 1) %>% 
    str_split_i("/", 2)
  TzetGenome <- seqinr::read.fasta(file = inputfile)
  print("TranslatingGenome")
  TranslatedTzet <- map(TzetGenome,
                        translate)
  write.fasta(sequences = TranslatedTzet,
              names = names(TranslatedTzet),
              file.out = paste("Translated", SpeciesCode, ".fasta", sep = ""), 
              open = "w",
              nbchar = 60, 
              as.string = FALSE) 
  
}

map(GenomeFiles, TranslatingGenomes)
