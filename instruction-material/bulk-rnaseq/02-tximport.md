# tximport


_You can read more about how to use these instructions, including the `<YOUR USER NAME>` notation, in [this section of the fastp and Salmon instructions.](https://github.com/jaclyn-taroni/2021-mdibl-fair/blob/main/instruction-material/bulk-rnaseq/01-fastp-salmon.md#how-to-use-these-directions)_

## Cooking show magic 🍳

Because the exploratory data analysis and differential gene expression modules downstream rely on the tximport output, we've created a "clean" version on the server that you can download with [`scp`](https://en.wikipedia.org/wiki/Secure_copy_protocol), which stands for secure copy protocol. 
We prepared this ahead of time because we expect that not all participants may be able to work on the fastp and Salmon exercise synchronously.

**In your local terminal** (⚠️ not when you are logged in to the server via `ssh`), run the following command replacing `<YOUR USER NAME>`, `<SERVER DOMAIN>`, and `<SOMEWHERE ON YOUR COMPUTER YOU WANT TO COPY THIS FILE TO>` with appropriate text (don't forget to remove the `<` and `>` when you replace the text!):

```sh
scp <YOUR USER NAME>@<SERVER DOMAIN>:/data/txi/goodale_data_tximport.RDS <SOMEWHERE ON YOUR COMPUTER YOU WANT TO COPY THIS FILE TO>
```

You will be prompted for your password, which you should type in and then hit enter. 

We'll read this data into RStudio at the end of this module so we can inspect it together and prepare for upcoming modules.

_Just in case this doesn't work, there is another copy of this data available for download [here](https://github.com/jaclyn-taroni/2021-mdibl-fair/raw/main/setup/bulk-rnaseq/tximport/goodale_data_tximport.RDS)._


## Running tximport

In this exercise, we'll import transcript-level output from `salmon quant` and
summarize it to the gene-level using [`tximport`](https://bioconductor.org/packages/release/bioc/html/tximport.html).
Gene-level abundance estimates have been demonstrated to be more accurate than transcript-level abundance estimates and differential expression analysis performed at the gene-level can be more robust and interpretable ([Soneson *et al.* 2015](http://dx.doi.org/10.12688/f1000research.7563.2)).
Depending on how the output of `tximport` is used, the approach can correct for potential changes in gene length across samples from differential isoform usage ([`tximport` vignette](https://bioconductor.org/packages/release/bioc/vignettes/tximport/inst/doc/tximport.html)).

For more information about `tximport`, see [this excellent vignette](https://bioconductor.org/packages/release/bioc/vignettes/tximport/inst/doc/tximport.html) from Love, Soneson, and Robinson.

### Using `run-tximport.R`

To run `tximport`, we need the `quant.sf` files for all the samples in an experiment and a file that maps between Ensembl transcript ids and Ensembl gene ids, which we've prepared ahead of time (see how [here](https://github.com/jaclyn-taroni/2021-mdibl-fair/blob/main/setup/bulk-rnaseq/scripts/prepare-tx2gene.R)) and put on the server.

**First, navigate back to the directory of `/data` that contains your own "personal" RNA-seq sample:**

```sh
cd /data/<YOUR USER NAME>
```

Then to run `tximport`, we'll use a script that's already on the server called `run-tximport.R`.
To make sure that everyone can write the `tximport` results to their own directory, we'll use command line arguments via a package called [`optparse`](https://cran.r-project.org/web/packages/optparse/index.html).

Specifically, `run-tximport.R` accepts two arguments:

* `--output_directory` which will be the absolute path of the directory on the server to save your output.
* `--output_filename` which will be the name of the `.RDS` file itself.

You can also use `--help` to see the help messages for these options like so: 

```
Rscript /data/scripts/run-tximport.R --help
```

**Use the following command to run the Rscript that carries out the `tximport` steps**:

```sh
Rscript /data/scripts/run-tximport.R \
  --output_directory /data/<YOUR USER NAME>/tximport \
  --output_filename goodale_data_tximport.RDS
```

### How `run-tximport.R` works

<details>
<summary> <b><i>Expand this section for a walk through of what the different sections of the <code>run-tximport.R</code> script are accomplishing</b></i> 🚀 </summary>

Let's walk through what the different sections of the `run-tximport.R` script are accomplishing (you can view this script on GitHub [here](https://github.com/jaclyn-taroni/2021-mdibl-fair/tree/main/instruction-material/bulk-rnaseq/scripts-for-server/run-tximport.R)).

⚠️ _Do not copy and paste this R code into the command line_ ⚠️

#### Required libraries

The first thing the script does is load the required packages into the environment with `library()`.

```R
#### Required libraries --------------------------------------------------------

library(tximport)
library(optparse)
```

#### Command line options

This section is what is required for using the command line arguments via `optparse`.
`option_list` is the list of command line options we create with [`make_option()`](https://www.rdocumentation.org/packages/optparse/versions/1.6.6/topics/make_option) from `optparse`, which we parse with [`parse_args()`](https://www.rdocumentation.org/packages/optparse/versions/1.6.6/topics/parse_args).

Don't worry about this too much – the most important point is that by using a command line option in this script , rather than ["hard coding"](https://en.wikipedia.org/wiki/Hard_coding) the output directory into the code itself, everyone in the course can use it for their purposes!

```r
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
```

The last step in this section tells R to report an error (which will _stop_ the script from continuing to run) if you do not specify anything to `--output_directory`.
By default `opt$output_directory` will be `NULL` (as set via `make_option()` above), so the [`stop()`](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/stop) in the [`if()`](http://applied-r.com/conditionals-in-r/#the-if-statement) statement will run if that argument is not used.

```R
# Error handling in case output directory is not specified
if (is.null(opt$output_directory)) {
  stop("You must specify where to save the tximport output with --output_directory!")
}

```

By placing this right after the command line options are parsed, we _fail early_ instead of waiting until we need to do something like write to file (which will required the output directory is specified!).
If we didn't fail early, we might waste time computing an object that we wouldn't be able to save as a file.

#### Files and directories 

This code will create the directory, including parent folders (`recursive = TRUE`), specified by `--output_directory`.
Steps like this prevent the scripts from failing to write the output file in case someone forgot to create the directory ahead of time.

```r
#### Files & directories -------------------------------------------------------

# Create the output directory if it doesn't exist yet
dir.create(opt$output_directory, showWarnings = FALSE, recursive = TRUE)

```

We next save the full filename, complete with path, to a variable called `txi_file`.
[`file.path()`](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/file.path) allows us to "paste" together the directory specified with `--output_directory` and the filename specified with `--output_filename`.

```r
# Set up output file path from options
txi_file <- file.path(opt$output_directory, opt$output_filename)
```

We need _everyone's_ "personal" Salmon quantification files to use `tximport`.
So, we'll list all the files in `/data` with the pattern `"quant.sf"` and assign their full paths to `salmon_files`.

```r
# List all quant files that folks processed
salmon_files <- list.files(path = "/data",
                           pattern = "quant.sf",
                           full.names = TRUE,
                           recursive = TRUE)
                           
```

Then, just in case there are any _other_ `quant.sf` files on the server in `/data`, we'll filter to only the relevant files by detecting the pattern `workshop-*` in the file paths (`*` is a wildcard).

```r

# Make sure these are files in "personal" data directories
# Which are in `/data/workshop-*`
salmon_files <- salmon_files[stringr::str_detect(salmon_files, "workshop-*")]

```

In the instructions for Salmon, everyone was asked to save their Salmon output in `/data/<USER NAME>/salmon/<SAMPLE IDENTIFIER>`.
The `quant.sf` will be in the `<SAMPLE IDENTIFIER>` directory, so the second to last "word" when we split by forward slashes (`/`) should be the sample identifier.

```r
# The sample identifier *should* always be the directory that contains the 
# quant.sf file
sample_identifiers <- stringr::word(salmon_files, -2, sep = .Platform$file.sep)

# In case folks have the same starting set of samples, we need to make these IDs
# unique with `make.names()`.
# In an ideal scenario, we'd handle any duplicates, too. We have a clean
# version of this data to be used with exploratory data analysis and edgeR, so
# we'll keep it simple for this exercise.
names(salmon_files) <- make.names(sample_identifiers, unique = TRUE)
```

In addition to the `quant.sf` files, `tximport()` requires that you provide it with a data frame with 2 columns: the first column should include transcript identifiers that match what you used with Salmon (typically Ensembl transcript IDs) and the second should include gene identifiers you wish to summarize to (typically Ensembl gene IDs).
We prepped that ahead of time and saved it as `/data/index/Homo_sapiens/Homo_sapiens_Ensembl_v103_tx2gene.tsv` on the server.

```r
# Transcript to gene mapping (tx2gene) required for tximport step 
tx2gene_file <- file.path("/data", "index", "Homo_sapiens",
                          "Homo_sapiens_Ensembl_v103_tx2gene.tsv")
```

#### tximport

We read in the transcript-to-gene tab-separated values file with `read_tsv()`. 
`read_tsv()` comes from the `readr` package.
We didn't load `readr` at the top of the script, so we can reference this function and this function only by using `::` nomenclature – `readr::read_tsv()`. 

```r
#### tximport ------------------------------------------------------------------

# Read in tx2gene TSV
tx2gene_df <- readr::read_tsv(tx2gene_file)
```

If we were to look at the first few rows of `tx2gene_df` (using `head()`), here's what we would see:

>```r
> head(tx2gene_df)
># A tibble: 6 x 2
>  tx_id           gene_id        
>  <chr>           <chr>          
> 1 ENST00000387314 ENSG00000210049
> 2 ENST00000389680 ENSG00000211459
> 3 ENST00000387342 ENSG00000210077
> 4 ENST00000387347 ENSG00000210082
> 5 ENST00000612848 ENSG00000276345
> 6 ENST00000386347 ENSG00000209082
> ```

Now we pass all of the paths to the quantification files and the transcript-to-gene data frame to `tximport()`, which will import all of the quant files and summarize the values to the gene-level by default.
We use `countsFromAbundance = "no"` (the default) to import the estimated counts from Salmon.

Above, you may have noticed that `tx2gene_df` uses identifiers that don't include [Ensembl version information](https://useast.ensembl.org/Help/Faq?id=488).
Version numbers follow a period (`.`) at the end of the identifier. 
For example, the second version of a human Ensembl transcript ID follows this pattern: `ENSTXXXXXXXXXX.2`.
The `quant.sf` files _do_ have version numbers, so we need to set `ignoreTxVersion = TRUE` for this to work!

```r
# tximport step
txi <- tximport(salmon_files, 
                type = "salmon", 
                tx2gene = tx2gene_df,
                countsFromAbundance = "no",
                ignoreTxVersion = TRUE)
```

Finally, we write to file with another `readr` function `write_rds()`. 
Recall that `txi_file` is created by "pasting" together the directory specified with `--output_directory` and the filename specified with `--output_filename`.

```r
# Save the tximport data as an RDS
readr::write_rds(txi, txi_file)
```

RDS is a special file format that we will cover in more detail below!

</details>


## Read into RStudio

 (don't forget to remove the `<` and `>` in your replacement):

```r
txi <- readr::read_rds("<SOMEWHERE ON YOUR COMPUTER YOU WANT TO COPY THIS FILE TO>")
```


