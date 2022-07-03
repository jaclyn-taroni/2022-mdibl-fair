# Reference Material

_Adapted in part from [Childhood Cancer Data Lab bulk RNA-seq training material](https://github.com/AlexsLemonade/training-modules/blob/9e648b207577c55cc22a24c712a736873523f5a4/RNA-seq)._

This is material we will not cover during the instruction due to time constraints.
We provide it for course participants who are particularly interested in QC and quanitfication of bulk RNA-seq data.


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*


- [Tools or methods](#tools-or-methods)
  - [FastQC](#fastqc)
      - [View FastQC reports for samples from instruction](#view-fastqc-reports-for-samples-from-instruction)
  - [MultiQC](#multiqc)
      - [View a MultiQC report for samples from instruction](#view-a-multiqc-report-for-samples-from-instruction)
  - [tximeta](#tximeta)
  - [refgenie](#refgenie)
  - [Decoy sequence-aware selective alignment with Salmon](#decoy-sequence-aware-selective-alignment-with-salmon)
- [Other courses or resources for continued learning](#other-courses-or-resources-for-continued-learning)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Tools or methods

### FastQC

FastQC is a popular tool for QC of FASTQ files. 
FastQC runs a series of quality checks on sequencing data and provides an HTML report. 
As the authors point out in the [docs](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/2%20Basic%20Operations/2.2%20Evaluating%20Results.html):

> It is important to stress that although the analysis results appear to give a pass/fail result, these evaluations must be taken in the context of what you expect from your library.

FastQC is pretty generic and there are certain modules you may always expect to warn or fail when running it on an RNA-seq library.
The [documentation for individual modules/analyses](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/) in FastQC is a great resource and will oftentimes point that out!

FastQC also runs on a single FASTQ file at a time.
If you have a paired-end RNA-seq sample, the duplication rates reported by FastQC will likely be an overestimation, as fastp (which we run during instruction) considers duplication rates using paired-end duplication analysis ([Chen *et al.* 2018](https://doi.org/10.1093/bioinformatics/bty560)).

If you haven't looked at many FastQC reports, some of the modules can be a little tricky to interpret.
We recommend checking out the [Michigan State University Research Technology Support Facility's “FastQC Tutorial & FAQ”](https://rtsf.natsci.msu.edu/genomics/tech-notes/fastqc-tutorial-and-faq/).

#### View FastQC reports for samples from instruction

We have generated FastQC reports for all samples we preprocess & quantify in class.
They are tracked in this repository here: <https://github.com/jaclyn-taroni/2022-mdibl-fair/setup/bulk-rnaseq/QC/fastqc_reports> You can view an HTML version of an individual FASTQ file by adding the filename to the end of this URL in your browser <https://jaclyn-taroni.github.io/2022-mdibl-fair/setup/bulk-rnaseq/QC/fastqc_reports> For example, you'd navigate to the following URL for the `1_ATCACG_L001_R1_combined_fastqc.html` report: <https://jaclyn-taroni.github.io/2022-mdibl-fair/setup/bulk-rnaseq/QC/fastqc_reports/1_ATCACG_L001_R1_combined_fastqc.html>


### MultiQC

[MultiQC](https://multiqc.info/) is a tool that aggregates output from many tools (over 111 are currently supported; see the list [here](https://multiqc.info/docs/#multiqc-modules)) into a single HTML report ([Ewels *et al.* 2016](http://dx.doi.org/10.1093/bioinformatics/btw354)).
It can be used to combine information, such as FastQC and fastp reports, for multiple RNA-seq samples in a project.
This can be helpful to get an overall picture of the samples in your experiment.
For example, fastp reports statistics before and after it processes samples.
If you were to perform _quality trimming_ with fastp and look at the before and after information across samples, it may tell you that, after trimming, a large portion of your reads were too short and were filtered out.
That's likely information you'd want to know when performing downstream analyses.
MultiQC supports the two tools we present in the bulk RNA-seq module: fastp and Salmon.
In addition, MultiQC is not limited to RNA-seq data; the website has example reports for Hi-C data and whole genome sequencing.

#### View a MultiQC report for samples from instruction

We generated a MultiQC report from the FastQC, fastp, and Salmon reports for the 12 samples we looked at during instruction.
You can view it [here](https://jaclyn-taroni.github.io/2022-mdibl-fair/setup/bulk-rnaseq/QC/multiqc_report.html).

### tximeta

`tximeta` is a Bioconductor package that extends the functionality of `tximport`.
We'll quote the abstract of [the `tximeta` vignette](https://www.bioconductor.org/packages/devel/bioc/vignettes/tximeta/inst/doc/tximeta.html) here:

> Tximeta performs numerous annotation and metadata gathering tasks on behalf of users during the import of transcript quantifications from Salmon or alevin into R/Bioconductor. Metadata and transcript ranges are added automatically, facilitating genomic analyses and assisting in computational reproducibility. 

Currently, there is [a limited number of supported organisms that work "out of the box."](https://www.bioconductor.org/packages/devel/bioc/vignettes/tximeta/inst/doc/tximeta.html#Pre-computed_checksums)

### refgenie

[refgenie](http://refgenie.databio.org/en/latest/) ([Stolarczyk *et al.* 2020](https://doi.org/10.1093/gigascience/giz149); [Stolarczyk *et al.* 2021](https://doi.org/10.1093/nargab/lqab036)) provides a command-line interface to download pre-built indices for many bioinformatic tools.
We use a pre-built Salmon cDNA index from refgenie during instruction.
Check out [the overview](http://refgenie.databio.org/en/latest/overview/) to get started.

### Decoy sequence-aware selective alignment with Salmon

Transcript abundance estimates from lightweight mapping approaches like Salmon can differ from abundance estimates derived from traditional alignment approaches in experimental data ([Srivastava _et al._ 2020](https://doi.org/10.1186/s13059-020-02151-8)).
This differs from the takeaway of most prior work comparing lightweight mapping and traditional alignment; this is very likely due to the typical focus on _simulated data_ rather than experimental data.

To provide better results than lightweight mapping alone, Salmon includes a "selective alignment" method that is less computationally costly than traditional alignment while still offering improvements over lightweight mapping.

To apply the selective alignment method, you will need to first have an index that includes not only the transcripts of interest, but also a set of other potentially mapped sequences.
One option is to include "decoy sequences" in Salmon index from genomic loci that are similar to annotated transcripts, to avoid falsely mapping fragments that arise from these unannotated regions to the transcripts of interest.
Alternatively (recommended), you can use the [_full genome_ as a decoy](https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/).

Instructions on creating such an index can be found in [the Salmon documentation](https://salmon.readthedocs.io/en/latest/salmon.html#preparing-transcriptome-indices-mapping-based-mode).
Or you can obtain indices for select organisms from refgenie; [here's a full genome version for human](http://refgenomes.databio.org/v3/assets/splash/2230c535660fb4774114bfa966a62f823fdb6d21acf138d4/salmon_sa_index?tag=default).


## Other courses or resources for continued learning

* [Harvard Chan Bioinformatics Core (HBC). _Introduction to RNA-Seq using high-performance computing_](https://hbctraining.github.io/Intro-to-rnaseq-hpc-salmon-flipped/schedule/links-to-lessons.html)
* [University of Michigan Bioinformatics Core. _Experimental Design, Library Preparation, and Sequencing._](https://umich-brcf-bioinf.github.io/rnaseq_demystified_workshop/site/Module3a_Design_Prep_Seq)
* [StatsQuest with Josh Starmer. _High Throughput Sequencing_ YouTube playlist.](https://www.youtube.com/playlist?list=PLblh5JKOoLUJo2Q6xK4tZElbIvAACEykp)
* [Cresko lab of the University of Oregon. _RNA-seqlopedia._](https://rnaseq.uoregon.edu)

