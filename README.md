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
## Let us have data located in a project named My_Project.
my_data <- "data/Projects/My_Project/Data/First_data"

## This will be the path to the result table
my_result <- paste(my_data,"_fc_result",sep="")

## This invokes the functional classification analysis according
## to disease/gene assocations in HumanPSD.
gx.analysis("Functional classification",
             list(sourcePath = my_data,
             species = "Human (Homo sapiens)",
             bioHub = "HumanPSD(TM) disease",
             outputTable = my_result));
                
## This command loads the result table into an R data frame.
data <- gx.get(my_result)
```

  
