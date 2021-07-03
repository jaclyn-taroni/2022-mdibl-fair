#!/bin/bash

set -e
set -o pipefail

# Set the working directory to the directory of this file
cd "$(dirname "${BASH_SOURCE[0]}")"

# Make directories to hold index
index_dir=../index/Homo_sapiens/
mkdir -p ${index_dir}

# wget from refgenie
# cDNA index
cdna_tgz=${index_dir}/salmon_index.tar.gz 
wget -O ${cdna_tgz} http://refgenomes.databio.org/v3/assets/archive/9a02d64909100f146272f8e16563178e9e93c218b1126ff9/salmon_index?tag=default
tar xvzf ${cdna_tgz} --directory ${index_dir}
mv ${index_dir}/default ${index_dir}/salmon_index
rm ${cdna_tgz}
