library(ape)
library(tidyverse)
library(googlesheets4)
#Make a gene tree object 
tree <- read.tree("/FungusFarmingGeneProject/03_TranslatedGenomesOrthoFinder/OrthoFinder/Results_May31/Resolved_Gene_Trees/OG0015881_tree.txt")

#Read in the google sheet Formicidae Genomes and assign to object
FormicidaeGenomes <- read_sheet("https://docs.google.com/spreadsheets/d/1Oe-ye8cIbKcW4Rt6HfWAGAl7X8ajHz34KKc5Gmsq_K8/edit?usp=sharing")

#Separate binomial into 2 columns, genus and species
FormicidaeGenomes <- separate_wider_delim(FormicidaeGenomes, cols = Species, delim = " ", names = c("Genus", "species"))

#Assign first letter of genus to GenusCode object
GenusCode <- str_sub(FormicidaeGenomes$Genus, 1, 1)

#Assign first 3 letters of species to SpeciesCode object 
SpeciesCode <- str_sub(FormicidaeGenomes$species, 1, 3)

#Paste the genus and species code objects together to make a column with combined species code
FormicidaeGenomes$SpeciesCode <- paste(GenusCode, SpeciesCode, sep = "")

#Filter the strictly fungus feeding column in the FormicidaeGenomes table for yes 
StrictlyFungusFeeding <- filter(FormicidaeGenomes, `Strictly fungus-feeding, y/n` == "yes")

#Make the Tips object with list of gene tree tip labels 
Tips <- tree[["tip.label"]]

#Assign matches 
Matches <- charmatch(StrictlyFungusFeeding$SpeciesCode, Tips) %>%
  na.omit() %>% 
  as.numeric()
MatchingTips <- Tips[Matches]
write(MatchingTips, "TipsToObject.txt")
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "/miniconda3/bin/hyphy", sep= .Platform$path.sep))
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "/FungusFarmingGeneProject/hyphy-analyses", sep= .Platform$path.sep))


#Make Hyphy Command that labels tree tips, but not internal nodes
HyphyCommand <- "/miniconda3/bin/hyphy hyphy-analyses/LabelTrees/label-tree.bf --tree ./03_TranslatedGenomesOrthoFinder/OrthoFinder/Results_May31/Resolved_Gene_Trees/OG0015881_tree.txt --list TipsToObject.txt --output testtree.txt --internal-nodes \"None\""

cat(HyphyCommand)
system(HyphyCommand)
