#!/usr/bin/Rscript --vanilla

#### Required libraries --------------------------------------------------------

library(tximport)
library(optparse)

#### Command line options ------------------------------------------------------

option_list <- list(
  make_option(
    opt_str = "--output_directory",
    type = "character",
    default = NULL,
    help = "A directory on the server where you can save your output, e.g., /data/<your username>/tximport",
  ),
  make_option(
    opt_str = "--output_filename",
    type = "character",
    default = "goodale_data_tximport.RDS",
    help = ".RDS to be saved in the directory specified by --output_directory",
  )
)

# Parse options
opt <- parse_args(OptionParser(option_list = option_list))

# Error handling in case output directory is not specified
if (is.null(opt$output_directory)) {
  stop("You must specify where to save the tximport output with --output_directory!")
}

#### Files & directories -------------------------------------------------------

# Create the output directory if it doesn't exist yet
dir.create(opt$output_directory, showWarnings = FALSE, recursive = TRUE)

# Set up output file path from options
txi_file <- file.path(opt$output_directory, opt$output_filename)

# List all quant files that folks processed
salmon_files <- list.files(path = "/data",
                           pattern = "quant.sf",
                           full.names = TRUE,
                           recursive = TRUE)

# Make sure these are files in "personal" data directories
# Which are in `/data/workshop-*`
salmon_files <- salmon_files[stringr::str_detect(salmon_files, "workshop-*")]

# The sample identifier *should* always be the directory that contains the 
# quant.sf file
sample_identifiers <- stringr::word(salmon_files, -2, sep = .Platform$file.sep)

# In case folks have the same starting set of samples, we need to make these IDs
# unique with `make.names()`.
# In an ideal scenario, we'd handle any duplicates, too. We have a clean
# version of this data to be used with exploratory data analysis and edgeR, so
# we'll keep it simple for this exercise.
names(salmon_files) <- make.names(sample_identifiers, unique = TRUE)

# Transcript to gene mapping (tx2gene) required for tximport step 
tx2gene_file <- file.path("/data", "index", "Homo_sapiens",
                          "Homo_sapiens_Ensembl_v103_tx2gene.tsv")

#### tximport ------------------------------------------------------------------

# Read in tx2gene TSV
tx2gene_df <- readr::read_tsv(tx2gene_file)

# tximport step
txi <- tximport(salmon_files, 
                type = "salmon", 
                tx2gene = tx2gene_df,
                countsFromAbundance = "no",
                ignoreTxVersion = TRUE)

# Save the tximport data as an RDS
readr::write_rds(txi, txi_file)
