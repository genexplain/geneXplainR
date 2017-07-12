[![Build Status](https://travis-ci.org/genexplain/geneXplainR.svg?branch=master)](https://travis-ci.org/genexplain/geneXplainR)
[![codecov](https://codecov.io/gh/genexplain/geneXplainR/branch/master/graph/badge.svg)](https://codecov.io/gh/genexplain/geneXplainR)

# geneXplainR

The geneXplainR package provides an R client for the 
[geneXplain platform](http://genexplain.com/genexplain-platform/) [1]. 
The geneXplain platform is an online toolbox and workflow management 
system for a broad range of bioinformatic and systems biology applications.
The platform is well-known for its upstream analysis [2], that has been
developed to identify causal signalling molecules on the basis of experimental data
like expression measurements.

geneXplainR is based on and extends the [rbiouml](https://cran.r-project.org/package=rbiouml) package.
A goal of this project is to add functionality that helps to make building R pipelines that use the geneXplain platform easier.

# Installation

## From github.com

The geneXplainR package can be easily installed from its github repository using *devtools*.

```R
library(devtools)
install_github("genexplain/geneXplainR")
```

We hope to make geneXplainR available through other channels as well, so that there will be further options
to download and install the software. 

# Usage

A script using geneXplain may look like this (please note that shown parameters won't work):

```R
library(geneXplainR)
gx.login("http://genexample.com/bioumlweb","user","password"),

# Get a listing of your research projects
gx.ls("data/Projects")
```
# Documentation and examples

For information about geneXplainR, please refer to the vignettes that come with this package. Furthermore, the *examples* branch of this repository contains a number of examples.

# References

1. Kel, A., Kolpakov, F., Poroikov, V., Selivanova, G. (2011) GeneXplain — Identification of Causal Biomarkers and Drug Targets in Personalized Cancer Pathways. J. Biomol. Tech. 22(suppl.), S1
2. Koschmann, J., Bhar, A., Stegmaier,P., Kel, A. E. and Wingender, E. (2015) “Upstream Analysis”: An integrated promoter-pathway analysis approach to causal interpretation of microarray data. Microarrays 4, 270-286.
