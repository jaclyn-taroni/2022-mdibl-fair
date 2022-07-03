#!/usr/bin/Rscript --vanilla

# Use AnnotationHub
library(AnnotationHub)
annotation_hub <- AnnotationHub()

# Homo sapiens hg38 Ensembl release 103
hs_ensembl_db <- annotation_hub[["AH89426"]]

# Get tx2gene data frame
hs_tx <- transcripts(hs_ensembl_db, return.type = "DataFrame")
tx2gene_df <- as.data.frame(hs_tx[, c("tx_id", "gene_id")])

# Detect the ".git" folder -- this will be in the project root directory.
# Use this as the root directory to ensure proper sourcing of functions no
# matter where this is called from
root_dir <- rprojroot::find_root(rprojroot::has_dir(".git"))

# Homo sapiens index directory
hs_index_dir <- file.path(root_dir, "setup", "bulk-rnaseq", 
	                      "index", "Homo_sapiens")
# Output file set up
tx2gene_file <- file.path(hs_index_dir, 
                          "Homo_sapiens_Ensembl_v103_tx2gene.tsv")

# Write to file
readr::write_tsv(tx2gene_df, tx2gene_file)
