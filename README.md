# Examples and documentation for geneXplainR

# Installation

## Using devtools

The package can be installed from the GitHub repository using [devtools](https://github.com/hadley/devtools).

```R
library(devtools)
install_github("genexplain/geneXplainR")
```

After successful installation the library can be loaded using this command:

```R
library(geneXplainR)
```

# First commands

Most function names in geneXplainR start with the prefix **gx**.

### gx.login
Firstly, one needs to log into a server to perform analyses using the
*gx.login* command.


```R
## Placeholders enclosed by <> need to be substituted by actual parameters
gx.login("<URL>","<username>","<password>")

## The URL argument may look like this: https://platform.genexplain.com
```

### gx.ls
One can list folders in the platform using the *gx.ls* command.

```R
## This shows the contents of your Projects folder
gx.ls("data/Projects")

## This shows the contents of one of the projects, where
## <project folder name> needs to be substituted by an
## actual project name.
gx.ls("data/Projects/<project folder name>")
```

### gx.analysis.*
The *gx.analysis.list* method returns a table with available analysis methods.

```R
gx.analysis.list()
```

An analysis tool is invoked using the *gx.analysis* method. The parameters
of a tool can be inspected using the *gx.analysis.parameters* method.
Applying a tool often involves these two methods (note the placeholders <> which need to be substituted):

```R
gx.analysis.parameters(<specified method>)
gx.analysis.parameters(<specified method>,list(<tool parameters>))
```
### Example
Performing a functional classification analysis on a gene set may
look like this:

```R
## Login to demo account
gx.login()

## Example data sets can be found under 'data/Examples'. Here we use a set of upregulated genes.
my_data <- paste0("data/Examples/TNF-stimulation of HUVECs GSE2639, ",
                  "Affymetrix HG-U133A microarray/Data/DEGs with limma/",
                  "Normalized (RMA) DEGs with limma/Condition_1 vs. Condition_2/",
                  "Up-regulated genes Ensembl")

## This will be the path to the result table. It will be put into the 'Demo project' provided
##  in this workspace.
my_result <- paste0("data/Projects/Demo project/Data/",
                    "my_demo_result_",
                    Sys.Date(),"_",
                    floor(runif(1, 1, 10^12)))

## This invokes the functional classification analysis according
## to the Gene Ontology.
gx.analysis("Functional classification",
             list(sourcePath = my_data,
             species = "Human (Homo sapiens)",
             bioHub = "Full gene ontology classification",
             outputTable = my_result));
                
## This command loads the result table into an R data frame.
data <- gx.get(my_result)
```

   
