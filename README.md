# FAIR 2022 

These materials are for instruction as part of MDIBL's 2022 Reproducible and FAIR Bioinformatics Analysis of Omics Data course.

They are adapted from [Alex's Lemonade Stand Foundation](https://www.alexslemonade.org/) [Childhood Cancer Data Lab](https://www.ccdatalab.org/) [training materials](https://github.com/AlexsLemonade/training-modules), [Harvard Chan Bioinformatics Core](http://bioinformatics.sph.harvard.edu/) lessons and [Penn GCB 535 materials](https://github.com/greenelab/GCB535).
(Sources used will be indicated in individual sections of instruction material.)


### Development with Docker

Build with:

```
# Use BuildKit with output that is easier to read
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Build the image itself 
docker build -t 2022-mdibl-fair docker/.
```

Run with:

```
docker run \
  --mount type=bind,target=/home/rstudio/2022-mdibl-fair,source=$PWD \
  -e PASSWORD=<PASSWORD> \
  -p 8787:8787 \
  2022-mdibl-fair
```
