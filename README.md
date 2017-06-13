# geneXplainR

The geneXplainR package provides an R client for the 
[geneXplain platform](http://genexplain.com/genexplain-platform/) [1]. 
The geneXplain platform is an online toolbox and workflow management 
system for a broad range of bioinformatic and systems biology applications.
The platform is well-known for its upstream analysis [2], that has been
developed to identify causal signalling molecules on the basis of experimental data
like expression measurements.

geneXplainR is based on and extends the [rbiouml](https://cran.r-project.org/web/packages/rbiouml/index.html) package.
A goal of this project is to add functionality that helps to make building R pipelines that use the geneXplain platform easier.

# Installation

## From github.com

The geneXplainR package can be easily installed from its github repository using *devtools*.

```R
library(devtools)
install_github("genexplain/geneXplainR")
```

# References

1. Kel, A., Kolpakov, F., Poroikov, V., Selivanova, G. (2011) GeneXplain — Identification of Causal Biomarkers and Drug Targets in Personalized Cancer Pathways. J. Biomol. Tech. 22(suppl.), S1
2. Koschmann, J., Bhar, A., Stegmaier,P., Kel, A. E. and Wingender, E. (2015) “Upstream Analysis”: An integrated promoter-pathway analysis approach to causal interpretation of microarray data. Microarrays 4, 270-286.
