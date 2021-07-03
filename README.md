# FAIR 2021 

These materials are for instruction as part of MDIBL's 2021 Reproducible and FAIR Bioinformatics course.

They are adapted from [Alex's Lemonade Stand Foundation](https://www.alexslemonade.org/) [Childhood Cancer Data Lab](https://www.ccdatalab.org/) [training materials](https://github.com/AlexsLemonade/training-modules).


### Development with Docker

Build with:

```
docker build -t 2021-mdibl-fair docker/.
```

Run with:

```
docker run \
  --mount type=bind,target=/home/rstudio/2021-mdibl-fair,source=$PWD \
  -e PASSWORD=<PASSWORD> \
  -p 8787:8787 \
  2021-mdibl-fair
```
