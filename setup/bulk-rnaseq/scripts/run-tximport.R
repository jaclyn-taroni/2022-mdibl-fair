#!/usr/bin/Rscript --vanilla

# Required library
library(tximport)

# Detect the ".git" folder -- this will be in the project root directory.
# Use this as the root directory to ensure proper sourcing of functions no
# matter where this is called from
root_dir <- rprojroot::find_root(rprojroot::has_dir(".git"))

# Directory for bulk RNA-seq material setup
rnaseq_dir <- file.path(root_dir, "setup", "bulk-rnaseq")

# Directory where salmon results for all samples are contained, each sample in
# it's own folder
quant_dir <- file.path(rnaseq_dir, "salmon")

# List all quant.sf files
sf_files <- list.files(
  quant_dir,
  recursive = TRUE,
  full.names = TRUE,
  pattern = "quant.sf"
)

# The sample identifier will always be the directory that contains the
# quant.sf file
sample_identifiers <-
  stringr::word(sf_files,-2, sep = .Platform$file.sep)
names(sf_files) <- sample_identifiers

# Read in tx2gene file
tx2gene_file <- file.path(
  rnaseq_dir,
  "index",
  "Homo_sapiens",
  "Homo_sapiens_Ensembl_v103_tx2gene.tsv"
)
tx2gene_df <- readr::read_tsv(tx2gene_file)

# tximport step
txi <- tximport(
  sf_files,
  type = "salmon",
  tx2gene = tx2gene_df,
  countsFromAbundance = "no",
  ignoreTxVersion = TRUE
)

# Save the tximport data as an RDS
txi_dir <- file.path(rnaseq_dir, "tximport")
dir.create(txi_dir, showWarnings = FALSE)
txi_file <- file.path(txi_dir, "goodale_data_tximport.RDS")
readr::write_rds(txi, txi_file)
