
#Download packages
library(tidyverse)
library(phylotools)

#Create ExampleOrthogroup object, read in orthogroup fasta file
ExampleOrthogroup <-phylotools::read.fasta("ExampleData/OrthoFinder/Results_Apr17/Orthogroup_Sequences/OG0001124.fa")

#Create ExampleGenome object, read in example genome fasta file
ExampleGenome <- phylotools::read.fasta("ExampleData/Mycoplasma_hyopneumoniae.faa")

#Create object to use all Genome files in ExampleData that are fasta files
ExampleGenomes <- list.files(path = "./ExampleData", 
           pattern = "*.faa",
           all.files = FALSE,
           full.names = TRUE)
ReadExampleGenomes <- map(ExampleGenomes, read.fasta)

#Create data frame that combines our orthogroup and genome data frames
CombinedGenomeDF <- bind_rows(ReadExampleGenomes, .id = "column_label")


#Splitting Genome column
CombinedGenomeDF$seq.name<- str_split_i(CombinedGenomeDF$seq.name, pattern = " ", i = 1)

#Match data frames by shared names
Sequence <- CombinedGenomeDF %>%
  filter(seq.name %in% ExampleOrthogroup$seq.name) %>% 
  select(-c("column_label"))


