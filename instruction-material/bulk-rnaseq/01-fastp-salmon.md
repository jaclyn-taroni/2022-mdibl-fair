# fastp and Salmon

## Introduction to the exercise

You will each preprocess and quantify a single paired-end RNA-seq sample with fastp and Salmon.
Your own "personal" FASTQ files can be found on the server in the `/data/<your user name>/raw` directory.
We will use everyone's Salmon output as input into an R package called `tximport`.


**Your objective is to complete the steps in this document prior to the start of our next session at 1pm Eastern tomorrow.** 

_If you run into difficulties and do not complete Salmon processing, that is totally okay!
We [include a worked example below](#worked-example) which you may find helpful!_

### How to use these directions

Below, we use the notation such as `<YOUR USER NAME>` or `<YOUR SAMPLE>` to indicate when you should replace some text with your user name or assigned sample identifier in your own directory.
**Make sure to remove the angled brackets `<` and `>` when you replace these with the appropriate text!**
These characters will cause trouble otherwise.

For example – if my user name on the server was `workshop-00`, I would replace `/data/<YOUR USERNAME>` with `/data/workshop-00`.

#### Sample identifiers 

For the purpose of this exercise, we will use _all text_ that comes before `_R1_combined.fastq.gz` and `_R2_combined.fastq.gz` in the raw FASTQ files that are distributed to you will be considered your sample identifier and should be used to replace `<YOUR SAMPLE>`. 

If I had the files `5_ACAGTG_L001_R1_combined.fastq.gz` and  `5_ACAGTG_L001_R2_combined.fastq.gz` in my `raw` directory, I would do the following when following the instructions below: 

* Replace `raw/<YOUR SAMPLE>_R1_combined.fastq.gz` with `raw/5_ACAGTG_L001_R1_combined.fastq.gz`
* Replace `salmon/<YOUR SAMPLE>` with `salmon/5_ACAGTG_L001`
* Replace `'<YOUR SAMPLE> report'` with `'5_ACAGTG_L001 report'`

#### Commands

All commands you need to enter into the command line on the server will be in a code block like the one below:

```sh
# Here's a command you need to enter into the command line!
# The # means that this is a comment and is not executed as a command.
```

After you type (or paste) the command, you will most likely need to **hit ENTER to run it**.

Backslashes `\` (without any spaces after them!) allow you to continue a command onto the next line. 
This can really help make commands easier to read as a human, so we use them below.

Importantly, that means **everything in a code block is intended to be pasted into the command line at the same time even if it's made up of multiple lines.**
To add a visual cue, we'll also indent everything that's a continuation of an earlier line.

The following would be equivalent to running `salmon swim` all on one line.


```
salmon \
  swim
```

#### Documenting expected output

When you see a quoted code block like the following:

> ```
> Here's where we're reporting expected output of a program
> ```

We're using it to report the output you can expect to see in the terminal in response to a command or as something is running.
**You should not copy and paste the contents of quoted code blocks into the command line.**

#### Using a text editor

Because you will need to alter the text in some of the code blocks below (e.g., replace `<YOUR USERNAME>` and `<YOUR SAMPLE>`), **you may find it helpful to use a text editor to copy the commands below, edit them to reflect your sample and filenames, and then copy and paste the updated command into the command line.**

You can use TextEdit on a Mac, Notepad on Windows, and [Sublime](https://www.sublimetext.com/) or [Atom](https://atom.io/) can be downloaded and used on multiple platforms.


## Setting up

First, you'll need to navigate to your "personal" data directory for this exercise with `cd`:

```sh
cd /data/<YOUR USER NAME>
```

Take a look at your "personal" FASTQ files with:

```
ls raw
```

`ls` lists the contents of a directory.

You should see one file that ends with `_R1_combined.fastq.qz` and one that ends with `_R2_combined.fastq.gz`. 
These are the raw read1 input and read2 (sometimes called left and right) files, respectively, for the sample you will be processing.

As a reminder, _all the text_ that comes before `_R1_combined.fastq.gz` and `_R2_combined.fastq.gz` in your FASTQ files will be used as `<YOUR SAMPLE>` in the commands below!

**Now let's make several directories to hold the output of the programs we'll run below.**

To create the directory that will hold the preprocessed FASTQ files, run the following:

```
mkdir -p trimmed
```

`mkdir`, as you may have guessed, makes directories!
The `-p` allows us to create _parent_ directories and will prevent an error if the directory we specify already exists.


To create the directory that will hold the fastp reports, run the following:

```
mkdir -p QC/fastp_reports
```

To make the directory that will hold the Salmon output, run the following:

```
mkdir -p salmon
```

Now check your work by listing the contents with `ls` like so:

```
ls
```

You should see the following:

> ```
> QC  raw  salmon  trimmed
> ```


## Preprocessing with fastp 

_Adapted from [Childhood Cancer Data Lab bulk RNA-seq training material](https://github.com/AlexsLemonade/training-modules/tree/9e648b207577c55cc22a24c712a736873523f5a4/RNA-seq)._

We use [fastp](https://github.com/OpenGene/fastp) to preprocess the FASTQ files ([Chen *et al.* 2018](https://doi.org/10.1093/bioinformatics/bty560)).
Note that fastp has quality control functionality and many different options for preprocessing (see [all options on GitHub](https://github.com/OpenGene/fastp/blob/master/README.md#all-options)), most of which we will not cover.
Here, we focus on adapter trimming, quality filtering, and length filtering.

To run `fastp`, edit the following command to match your files:

```
fastp \
 --in1 raw/<YOUR SAMPLE>_R1_combined.fastq.gz --in2 raw/<YOUR SAMPLE>_R2_combined.fastq.gz \
 --out1 trimmed/<YOUR SAMPLE>_R1_combined.fastq.gz --out2 trimmed/<YOUR SAMPLE>_R2_combined.fastq.gz \
 --qualified_quality_phred 15 \
 --length_required 15 \
 --detect_adapter_for_pe \
 --html QC/fastp_reports/<YOUR SAMPLE>_fastp.html \
 --json QC/fastp_reports/<YOUR SAMPLE>_fastp.json \
 --report_title '<YOUR SAMPLE> report'
```

Below, we'll walk through the arguments/options we used to run `fastp`.
By default, fastp performs adapter trimming, which you can read more about [here](https://github.com/OpenGene/fastp#adapters).

### fastp arguments and options

#### Input: `-in1` and `-in2`

These arguments specify the read1 input and read2 (sometimes called left and right) input, respectively.

#### fastq output: `-out1` and `-out2`

These arguments specify the read1 output and read2 output, respectively.
Note that the output is being placed in the `trimmed/` directory you created earlier, so the processed FASTQ files will be kept separate from from the original files.
It is generally good practice to treat your "raw" data and its directories as fixed and separate from any processing and analysis that you do, to prevent accidentally modification of those original files. 
And in the event that you accidentally do modify the originals, you know exactly which files and directories to reset.

#### `--qualified_quality_phred`

[Phred scores](https://en.wikipedia.org/wiki/Phred_quality_score) are the quality information included in a FASTQ file and the values indicate the chances that a base is called incorrectly.
Q20 (a Phred score of 20) represents a 1 in 100 chance that the base call is incorrect and is often used as the cutoff for good quality calls.
Because of how the Phred score is calculated, the error rate increases quite rapidly as you head towards zero after Q20 (see [this post on Phred scores from the GATK Team](https://gatk.broadinstitute.org/hc/en-us/articles/360035531872-Phred-scaled-quality-scores)).

Here we're using `--qualified_quality_phred 15` to stick with the default setting, which means scores >= 15 are considered "qualified."

_Quality trimming_, in contrast to filtering, refers to removing low quality base calls from the (typically 3') end of reads.
A recent paper from the Salmon authors ([Srivastava _et al._ 2020](https://doi.org/10.1186/s13059-020-02151-8)) notes that trimming did not affect mapping rates from random publicly available human bulk (paired-end) RNA-seq samples (they used [TrimGalore](https://github.com/FelixKrueger/TrimGalore)).
fastp does have [the functionality](https://github.com/OpenGene/fastp#per-read-cutting-by-quality-score) to perform trimming using a sliding window, which must be enabled.
We are not using it here!

#### `--length_required`

Trimming reads may result in short reads, which may affect gene expression estimates ([Williams *et al.* 2016.](https://doi.org/10.1186/s12859-016-0956-2)).
Using `--length_required 15` means that reads shorter than 15bp will be discarded (and is the default setting).

#### `--detect_adapter_for_pe`

This enables auto-detection of adapter sequences in paired-end reads, since we are not specifying the adapter sequences ourselves.
Adapter sequencers are observed in the 3' end of RNA-seq reads when the cDNA insert (molecule to be sequenced) is shorter than the number of bases sequenced ([ref](https://www.ecseq.com/support/ngs/trimming-adapter-sequences-is-it-necessary) <- definitely check this out if you're looking for a more extensive explanation!).

Because they're synthentic, adapter sequences won't map to the transcriptome.
It's worth acknowledging that whether or not this step is _necessary_ is subject to debate and may be harmful to gene expression estimates if it results in very short reads (see `--length_required` above).

#### `--report_title`

When we look at the HTML report, it's helpful to quickly identify what sample the report is for. Using `--report title '<YOUR SAMPLE> report'` means that the report's title will include your sample identifier rather than the default ("fastp report").

#### `--json` and `--html`

With these options, we're specifying where the [JSON](https://en.wikipedia.org/wiki/JSON) and HTML reports will be saved (in the `QC/fastp_reports/` directory we created) and what the filenames will be.
Including the sample name in the filenames again may help us with project organization.

### What to expect when `fastp` is running

⚠️ `fastp` will take a few minutes to run!
You should expect to see output like the following in the command line when it starts:

> ```
> Detecting adapter sequence for read1...<br>
\>Illumina TruSeq Adapter Read 1<br>
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA

> Detecting adapter sequence for read2...<br>
> \>Illumina TruSeq Adapter Read 2<br>
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
> ```

It will also report a lot of the QC information as a message when it finishes, too.

### What to expect when `fastp` has finished running

The last message from `fastp` before it finishes running looks like (don't worry, your time used might be different!):

> ```
> fastp v0.20.1, time used: 340 seconds
> ```

The terminal interface will also look something like the following (where `wrkshp00` and `workshop-00` will be replaced with your user name) to let you know it's ready to accept another command!

> ```
> [wrkshp00 /data/workshop-00]$ 
> ```

If you run the following to list the contents of the `trimmed/` directory, you should see two FASTQ files that correspond to R1 and R2:

```
ls trimmed
```


## Quantifcation with Salmon

_Adapted in part from [this lession](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html) developed by members of the teaching team at the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/) and from [Childhood Cancer Data Lab bulk RNA-seq training material](https://github.com/AlexsLemonade/training-modules/tree/9e648b207577c55cc22a24c712a736873523f5a4/RNA-seq)._

We'll use [Salmon](https://combine-lab.github.io/salmon/) for quantifying transcript expression ([documentation](http://salmon.readthedocs.io/en/latest/)).
Salmon ([Patro *et al.* 2017](https://doi.org/10.1038/nmeth.4197)) is fast and requires very little memory!
We can use the output for downstream analyses like differential expression analysis and clustering.

To run `salmon quant`, the quantification command, edit the following command to match your files:

```
salmon quant \
  -i /data/index/Homo_sapiens/salmon_index \
  -l A \
  -1 trimmed/<YOUR SAMPLE>_R1_combined.fastq.gz -2 trimmed/<YOUR SAMPLE>_R2_combined.fastq.gz \
  -o salmon/<YOUR SAMPLE> \
  --threads 4 \
  --validateMappings \
  --gcBias \
  --seqBias
```

Salmon performs "quasi-mapping," which means it avoids traditional base-to-base alignment and instead estimates where reads best map to the transcriptome by identifying where informative sequences within the read map ([Srivastava *et al.* 2016](https://doi.org/10.1093/bioinformatics/btw277); [HBC Training](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html)).

Salmon will also generate transcript abundance estimates that are corrected for sample-specific biases or factors ([Patro *et al.* 2017](https://doi.org/10.1038/nmeth.4197)) and in a way that allows for multi-mapping (e.g., reads that map well to multiple transcripts are allocated to multiple transcripts in a way that maximizes a global likelihood, rather than thrown out; see [this Salmon issue](https://github.com/COMBINE-lab/salmon/issues/107)). 

For a more in-depth discussion of quasi-mapping and quantification, see [this material](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html#quasi-mapping-and-quantification) from the teaching team at the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/).
You may also want to check out [this talk from Carl Kingsford](https://www.youtube.com/watch?v=TMLIxwDP7sk), senior author of the Salmon paper ([Patro *et al.* 2017](https://doi.org/10.1038/nmeth.4197)).

### Salmon arguments and options

#### Transcriptome index: `-i`

Salmon requires a set of transcripts (what we want to quantify) in the form of a transcriptome index built with `salmon index`.
The transcriptome includes all known transcripts/splice isoforms for all genes.
Importantly, this means we can't use Salmon to detect novel genes, isoforms, or anything that's not present in the transcriptome used to build the index!
By extension, if you are attempting to quantify transcripts from an organism that doesn't have a particularly well-characterized reference transcriptome, Salmon may not be the tool for you.

The index evalutes the sequences for all possible unique sequences of length _k_ (this is called a k-mer; here _k_ is set to 31, which is appropriate for the length reads we're working with today.)
Salmon uses the reference index to determine position and orientation for where fragments best map prior to quantification ([Srivastava *et al.* 2016](https://doi.org/10.1093/bioinformatics/btw277); [HBC Training](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html)). k-mers in reads that are not in the index are not counted.

Building an index can take a while (but you only have to do it once per organism/genome build combination!), so we've acquired [the one we'll use today](http://refgenomes.databio.org/v3/assets/splash/9a02d64909100f146272f8e16563178e9e93c218b1126ff9/salmon_index?tag=default) from a resource called [`refgenie`](http://refgenie.databio.org/en/latest/).
You can view the Salmon instructions for building a cDNA index [here](https://combine-lab.github.io/salmon/getting_started/#indexing-txome).

#### `-l`

We use `-l A` to allow Salmon to automatically infer the sequencing library type based on a subset of reads, but you can also provide the [library type](http://salmon.readthedocs.io/en/latest/salmon.html#what-s-this-libtype) to Salmon with this argument.

#### Input: `-1` and `-2`

These data are paired-end, we use `-1` and `-2` to specify read1 and read2, respectively.
Notice how we are using the output of `fastp`, so these FASTQ files have undergone preprocessing.

#### `-o`

Output directory, `salmon quant` will create this for us if it doesn't exist yet.

#### [`--threads`](https://salmon.readthedocs.io/en/latest/salmon.html#p-threads)

The `--threads` argument controls the number of threads that are available to Salmon during quantification.
This in essence controls how much of the mapping can occur in parallel.
If you had access to a computer with many cores, you could increase the number of threads to make quantification go faster!

#### [`--validateMappings`](https://salmon.readthedocs.io/en/latest/salmon.html#validatemappings)

Using `--validateMappings` enables mapping validation, where Salmon checks its mappings using traditional alignment.
This helps prevent "spurious mappings" where a read maps to a target but does not arise from it (see [documentation for flag](https://salmon.readthedocs.io/en/latest/salmon.html#validatemappings) and the [release notes for `v0.10.0`](https://github.com/COMBINE-lab/salmon/releases/tag/v0.10.0) where this was introduced).
This is now run by default and is generally recommended by the Salmon authors!

#### [`--gcBias`](https://salmon.readthedocs.io/en/latest/salmon.html#gcbias)

With this option enabled, Salmon will attempt to correct for fragment GC-bias.
Regions with high or low GC content tend to be underrepresented in sequencing data.
RNA-seq samples may also have variable GC content dependence.
Using this flag generally results in more accurate transcript abundance estimation.

Check out [this blog post from Mike Love](https://mikelove.wordpress.com/2016/09/26/rna-seq-fragment-sequence-bias/) (includes a link to a short video!) and the paper it's about ([Love *et al.* 2016.]()) for more information.

Per [the Salmon docs](https://salmon.readthedocs.io/en/latest/salmon.html#gcbias), you can look at whether or not your samples exhibit strong GC bias with FastQC followed by [MultiQC with transcriptome GC distributions](https://multiqc.info/docs/#theoretical-gc-content), but _enabling this option for samples without GC bias does not impair quantification_; it only means this will take a bit longer to run!

It should be noted that this is only appropriate for use with paired-end reads, as fragment length can not be inferred from single-end reads (see [this GitHub issue](https://github.com/COMBINE-lab/salmon/issues/83)).

#### [`--seqBias`](https://salmon.readthedocs.io/en/latest/salmon.html#seqbias)

With this option enabled, Salmon will attempt to correct for the bias that occurs when using random hexamer priming (preferential sequencing of reads when certain motifs appear at the beginning); many RNA-seq experiments do use random hexamer priming!

We know that this experiment shows evidence of random hexamer priming by looking at FastQC reports ([example](https://jaclyn-taroni.github.io/2021-mdibl-fair/setup/bulk-rnaseq/QC/fastqc_reports/5_ACAGTG_L001_R1_combined_fastqc.html#M4)).
We don't cover FastQC here, but you can read more about it [in reference material we've prepared for you](https://jaclyn-taroni.github.io/2021-mdibl-fair/instruction-material/bulk-rnaseq/00-reference-material.md#fastqc).

You can read more about biases that arise from random hexamer priming in [Hansen *et al.* (2010)](https://doi.org/10.1093/nar/gkq224).


### What to expect when `salmon quant` is running

⚠️ `salmon quant` will take awhile to run (~10 min when your instructor was testing)!
You should expect to see output like the following in the command line when it starts:

>```
>### salmon (selective-alignment-based) v1.5.1
### [ program ] => salmon 
### [ command ] => quant 
### [ index ] => { /data/index/Homo_sapiens/salmon_index }
### [ libType ] => { A }
### [ mates1 ] => { trimmed/<YOUR SAMPLE>_R1_combined.fastq.gz }
### [ mates2 ] => { trimmed/<YOUR SAMPLE>_R2_combined.fastq.gz }
### [ output ] => { salmon/<YOUR SAMPLE> }
### [ threads ] => { 4 }
### [ validateMappings ] => { }
### [ gcBias ] => { }
### [ seqBias ] => { }
>```

`salmon quant` is pretty verbose and will keep updating you on what it's doing with messages!

### What to expect when `salmon quant` has finished running

The last message you should see before `salmon quant` finishes running will look something like:

>```
>[<DATE> <TIME>] [jointLog] [info] writing output 
>```

If you run the following, you should see a directory named with your sample's identifier.

```
ls salmon
```

Take a look at the files `salmon quant` output with the following command:

```
ls salmon/<YOUR SAMPLE>
```

You should see folders, JSON files, and a file called `quant.sf`.

>```
> aux_info  cmd_info.json  lib_format_counts.json  libParams  logs  quant.sf
>```

`quant.sf` is the quantification output from Salmon, which we'll use in our next step (`tximport`) and we will examine in the next step.
If you don't see `quant.sf`, but you do see some of the other 

## Examining the output

_Adapted in part from [this lession](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html) developed by members of the teaching team at the [Harvard Chan Bioinformatics Core (HBC)](http://bioinformatics.sph.harvard.edu/)._

In this section, we'll use a tool called `less` to examine some of the output from fastp and Salmon via the command line.
[`less`](https://en.wikipedia.org/wiki/Less_(Unix)) can be used to view (but not edit!) the context of a text file from the command line.

First, let's look at some of the QC information from fastp:

```
less QC/fastp_reports/<YOUR SAMPLE>_fastp.json
```

You can use your up and down arrow keys to scroll through this file.
Type `q` to quit `less`!

Of particular interest are the `summary`, `filtering_result`, and `duplication` fields, which can give you an idea of how much preprocessing (e.g., filtering, trimming) occurred. 

fastp also outputs HTML reports. 
You can see an example HTML fastp report for one of the samples in this experiment here:  <https://jaclyn-taroni.github.io/2021-mdibl-fair/setup/bulk-rnaseq/QC/fastp_reports/5_ACAGTG_L001_fastp.html>

If the vast majority of your reads were filtered out via this process, that would be cause for concern!

Now, use the following to examine the quantification file from Salmon:

```
less salmon/<YOUR SAMPLE>/quant.sf
```

The columns of this (tab-separated) file contain ([Salmon docs on quantification file output](https://salmon.readthedocs.io/en/latest/file_formats.html#quantification-file)):

* Name of the target transcript
* Length of target transcript
* The effective length represents the various factors that effect the length of transcript (i.e., degradation, technical limitations of the sequencing platform) ([HBC Training](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html))
* TPM, or transcripts per million, are the abundance estimates output by Salmon computed using the effective length ([HBC Training](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon/lessons/04_quasi_alignment_salmon.html)).
TPM attempts to normalize for sequencing depth and length. 
Check out [_RPKM, FPKM, and TPM, clearly explained_ from StatsQuest](https://www.rna-seqblog.com/rpkm-fpkm-and-tpm-clearly-explained/) and, more generally, [this table of common normalization methods for RNA-seq data](https://hbctraining.github.io/DGE_workshop_salmon/lessons/02_DGE_count_normalization.html#common-normalization-methods) from HBC training to learn more.
* Estimated number of reads that map to each transcript that was quantified.

Again, when you're ready to stop scrolling through the `quant.sf` file, type `q`!


## Worked example

<details>
<summary> Expand this section to reveal a fully worked example in case you get stuck or the instructions are unclear!</summary>

These values will not be exactly the same as what you need to enter!
They are specific to the example user name and samples.

```
cd /data/workshop-00
mkdir -p trimmed
mkdir -p QC/fastp_reports
mkdir -p salmon
```

```
fastp \
 --in1 raw/5_ACAGTG_L001_R1_combined.fastq.gz --in2 raw/5_ACAGTG_L001_R2_combined.fastq.gz \
 --out1 trimmed/5_ACAGTG_L001_R1_combined.fastq.gz --out2 trimmed/5_ACAGTG_L001_R2_combined.fastq.gz \
 --detect_adapter_for_pe \
 --qualified_quality_phred 15 \
 --length_required 15 \
 --html QC/fastp_reports/5_ACAGTG_L001_fastp.html \
 --json QC/fastp_reports/5_ACAGTG_L001_fastp.json \
 --report_title '5_ACAGTG_L001 report'
```

``` 
salmon quant \
  -i /data/index/Homo_sapiens/salmon_index \
  -l A \
  -1 trimmed/5_ACAGTG_L001_R1_combined.fastq.gz -2 trimmed/5_ACAGTG_L001_R2_combined.fastq.gz \
  -o salmon/5_ACAGTG_L001 \
  --threads 4 \
  --validateMappings \
  --gcBias \
  --seqBias
```

</details>

