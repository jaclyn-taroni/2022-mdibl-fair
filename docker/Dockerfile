FROM rocker/tidyverse:4.0.5
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
  'R.utils', \
  'rprojroot' \
  'tidymodels', \
  'umap' \
))"

# Install PLIER from github
RUN R -e "remotes::install_github('wgmao/PLIER', ref = 'd9c46d46873444103edb47f29e322b16513fd597')"

# Snakemake
ENV SNAKEMAKE_VERSION 5.19.3
RUN pip3 install snakemake==${SNAKEMAKE_VERSION}

# MultiQC
ENV MULTIQC_VERSION 1.9
RUN pip3 install multiqc==${MULTIQC_VERSION}

# FastQC
RUN apt update && apt install -y fastqc

# fastp 
ENV FASTP_VERSION 0.20.1
RUN git clone https://github.com/OpenGene/fastp.git
RUN cd fastp && \
    git checkout tags/v${FASTP_VERSION} -b v${FASTP_VERSION} && \
    make && \
    make install 

# Salmon
ENV SALMON_VERSION 1.4.0
WORKDIR /usr/local/src
RUN wget --quiet https://github.com/COMBINE-lab/salmon/releases/download/v${SALMON_VERSION}/salmon-${SALMON_VERSION}_linux_x86_64.tar.gz
RUN tar xzf salmon-${SALMON_VERSION}_linux_x86_64.tar.gz && \
    rm -f salmon-${SALMON_VERSION}_linux_x86_64.tar.gz && \
    ln -s /usr/local/src/salmon-latest_linux_x86_64/bin/salmon /usr/local/bin/salmon

WORKDIR /home/rstudio
