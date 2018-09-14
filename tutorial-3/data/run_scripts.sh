#!/bin/bash

cd ../script_00_Intro
Rscript api_intro.R
cd ../script_02_DE_gene_analysis
Rscript analyze_gene_expression.R
cd ../script_03_enhancer_analysis
Rscript analyze_enhancers.R
cd ../script_04_regulator_search
Rscript analyze_upstream_regulators.R

