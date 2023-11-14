# Comparative Genomics Selection on Ant Diet Related Genes Project
## 1. Download Genomes 
In order to work with the ant genomes you've chosen, you first must write a script to download them

- Create a list of genomes. For each genome, include the URL and an identifier separated by a comma.
  ex.  >https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/341/155/GCA_020341155.1_Ebur_v1.0/GCA_020341155.1_Ebur_v1.0_cds_from_genomic.fna.gz,Ebur 
  
- To move through this list, you can use a script with a while loop. The loop should use the lines of your genome list, separating the text at the comma. After creating  a variable containing the url, you can do the same with the identifier (speciesCode in this case). Use the identifier to create file names
  ex. 
  > $speciesCode'_genomeAssembly.fna.gz'
  
 - Next, you must download the genomes in the loop and unzip them. 
 
 -Finally, before closing your loop, create a new folder for your unedited genomes and copy the files into it
 
 ## 2. CleaningGeneNamesScript

-Use a while loop to move through the unedited genomes and replace certain characters (parentheses and dashes) with underscores in the filename. 

ex. 
>sed -i -e 's/-/_/g' $filename

-Next, make a directory and move the edited genome files into it. 


## 3. TransDecoder
To convert nucleotide sequences in your genomes to amino acid sequences, you'll need to use TransDecoder
 
 For your script, you can use a while loop to:
 
 - Extract long orfs
 - Predict likely coding regions
 - Make a TransDecoderGenomes folder to store translated genomes  
