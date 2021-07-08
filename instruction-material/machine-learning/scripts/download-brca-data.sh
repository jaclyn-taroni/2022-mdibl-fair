#!/bin/bash

set -e
set -o pipefail

# Set the working directory to the directory of this file
cd "$(dirname "${BASH_SOURCE[0]}")"

expression_dir=../data/expression/
metadata_dir=../data/metadata

mkdir -p ${expression_dir}
wget --quiet -O ${expression_dir}/METABRIC_dataset.pcl "https://github.com/greenelab/GCB535/raw/201186ec99735bc3cce3d6d7d6f0171a94cf1d06/29_Data_ML-II/METABRIC_dataset.pcl"
wget --quiet -O ${expression_dir}/TCGA_dataset.pcl "https://github.com/greenelab/GCB535/raw/201186ec99735bc3cce3d6d7d6f0171a94cf1d06/29_Data_ML-II/TCGA_dataset.pcl"

mkdir -p ${metadata_dir}
wget --quiet -O ${metadata_dir}/metabric_tumor_normal_label.txt "https://github.com/greenelab/GCB535/raw/201186ec99735bc3cce3d6d7d6f0171a94cf1d06/29_ML-II/tumor_normal_label.txt"
wget --quiet -O ${metadata_dir}/TCGA_subtype_label.txt "https://github.com/greenelab/GCB535/raw/201186ec99735bc3cce3d6d7d6f0171a94cf1d06/29_ML-II/BRCA.547.PAM50.SigClust.Subtypes.txt"
