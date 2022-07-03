FROM rocker/tidyverse:4.1.3
WORKDIR /rocker-build/

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install dialog apt-utils -y

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    autoconf \
    build-essential \
    ca-certificates \
    curl \
    g++ \
    gcc \
    git \
    groff \
    less \
    libboost-all-dev \
    libbz2-dev \
    libglpk-dev \
    liblzma-dev \
    libmagick++-dev \
    libmariadbclient-dev \
    libmariadbd-dev \
    libpq-dev \
    libproj-dev \
    libsqlite-dev \
    libssh2-1-dev \
    libxml2 \
    libxml2-dev \
    make \
    pandoc \
    python3-pip \
    time \
    unzip \
    zlib1g-dev 

# Bioconductor packages I know we'll need
RUN R -e "options(warn = 2); BiocManager::install(c( \
    'AnnotationHub', \
    'ConsensusClusterPlus', \
    'ensembldb', \
    'GEOquery', \
    'tximport' \
))"

# CRAN/RSPM
RUN R -e "install.packages(c( \
  'caret', \
  'e1071', \
  'glmnet', \
  'kernlab', \
  'markdown', \
  'R.utils', \
  'rprojroot', \
  'tidymodels', \
  'umap' \
))"

# Install PLIER from github
RUN R -e "remotes::install_github('wgmao/PLIER', ref = 'baf0dd488cf97752de657fcb7c39fcc994e9440d')"

# conda
# https://github.com/tschaffter/rstudio/blob/3aec9b6ca888c06121e6e3f269eefa8b4190c5e7/Dockerfile
ENV MINICONDA3_VERSION py39_4.12.0
ENV MINICONDA_BIN_PATH="/opt/miniconda/bin"
ENV PATH="${PATH}:${MINICONDA_BIN_PATH}"
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA3_VERSION}-Linux-x86_64.sh && \
    bash Miniconda3-${MINICONDA3_VERSION}-Linux-x86_64.sh \
        -b \
        -p /opt/miniconda && \
    rm -f Miniconda3-${MINICONDA3_VERSION}-Linux-x86_64.sh && \
    useradd -u 1500 -s /bin/bash miniconda && \
    chown -R miniconda:miniconda /opt/miniconda && \
    chmod -R go-w /opt/miniconda

# Add conda channels
RUN conda config --add channels defaults
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge

# Versions of software to be installed with conda
ENV FASTP_VERSION 0.23.2
ENV SALMON_VERSION 1.9.0
ENV MULTIQC_VERSION 1.13a
ENV SNAKEMAKE_VERSION 7.8.5
ENV FASTQC_VERSION 0.11.9 

# Install conda packages
RUN conda install fastp=${FASTP_VERSION}
RUN conda install salmon=${SALMON_VERSION} 
RUN conda install snakemake=${SNAKEMAKE_VERSION}
RUN conda install fastqc=${FASTQC_VERSION}
RUN conda install multiqc=${MULTIQC_VERSION}

WORKDIR /home/rstudio
