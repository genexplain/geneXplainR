#
# Drug discovery workflow from multi-omics to compound
# ECCB 2018
# Tutorial 3, Script 01
# Author:  Philip Stegmaier, philip.stegmaier@genexplain.com
# Version: 2018-09-09
#
# Optional script.
#
# Calculates differential expression of genes for several
# contrasts using limma on the basis of gene-wise read counts
# obtained from RNA-seq experiments available in GEO series GSE100382.
#
# This is a preliminary script that is not required, because all files for
# subsequent steps are already prepared in the data folder. Please note
# that executing this script requires several external libraries.
#
library(limma)
library(ggplot2)
library(ggfortify)
library(sva)
library(edgeR)
# Reads table with sample information
targets <- read.table("rna_seq_targets.txt", header=T, row.names=1, sep="\t")
# Creates columns with combined IFN and TNF as well as IFN, TNF and LPS status
targets$IFN.TNF     <- paste(targets$IFN,targets$TNF,sep=".")
targets$IFN.TNF.LPS <- paste(targets$IFN,targets$TNF,targets$LPS,sep=".")
# Reads count matrix created by subreads package
counts  <- read.table("rna_seq_data_matrix.txt", header=T, sep="\t", row.names=1)
# This follows the Limma user guide to omit low-count genes
dge <- DGEList(counts=counts)
A   <- rowSums(dge$counts)
dge <- dge[A>10,, keep.lib.sizes=FALSE]
# Adjustment for different sequencing depths
dge <- calcNormFactors(dge)
# Creates model matrix for SVA and Limma
design <- model.matrix(~0 + factor(targets$IFN.TNF.LPS))
colnames(design) <- levels(factor(targets$IFN.TNF.LPS))
# Normalize counts using Limma's voom function
vm  <- voom(dge, design, plot=TRUE, normalize.method="quantile")
# Sets up null model for SVA
sva.null <- model.matrix(~1, data=targets)
print("Running SVA")
# Estimates number of surrogate variables
n.sv  <- num.sv(vm$E, design, method="leek")
# Runs SVA
svobj <- sva(vm$E, design, sva.null)
# Removes additional latent effects found by SVA
cor.mat <- removeBatchEffect(vm$E, covariates = svobj$sv[,1:svobj$n.sv])
# Limma workflow using the matrix obtained from SVA
fit <- lmFit(cor.mat, design)
# Prepares a plot of first two principal components to visualize distribution of different factors
pcs <- prcomp(t(as.matrix(cor.mat)))
targets$PC1 <- pcs$x[,1]
targets$PC2 <- pcs$x[,2]
ggplot(targets, aes(x=PC1,y=PC2, color=IFN.TNF, shape=LPS)) + guides(fill=F)  + labs(colour="IFN.TNF") + geom_point(size=3)
ggsave("GSE100382_RNAseq_voom_SVA.tiff", device="tiff", dpi=600, width = 20, height = 20, units = "cm", compress="lzw")
# Stores SVA data matrix
write.table(cbind("Gene"=row.names(dge$counts),cor.mat), file="GSE100382_RNAseq_voom_SVA_matrix.txt", row.names=F, sep="\t", quote=F)
# Limma workflow to fit specific contrasts of interest
cont.matrix <- makeContrasts(IFN = ifn.none.none - none.none.none,
			     TNF = none.tnf.none - none.none.none,
			     LPS = none.none.lps - none.none.none,
			     TNF.LPS = (none.tnf.lps - none.none.lps),
			     IFN.TNF = (ifn.tnf.none - ifn.none.none),
			     levels=design)
fit2 <- contrasts.fit(fit, cont.matrix)
fit2 <- eBayes(fit2)
tt <- topTable(fit2, coef="IFN",number=1e10);
write.table(cbind("Gene"=rownames(tt),tt), file="../data/GSE100382_RNAseq_voom_SVA_IFN.txt", row.names=F, sep="\t", quote=F)
tt <- topTable(fit2, coef="TNF",number=1e10);
write.table(cbind("Gene"=rownames(tt),tt), file="../data/GSE100382_RNAseq_voom_SVA_TNF.txt", row.names=F, sep="\t", quote=F)
tt <- topTable(fit2, coef="LPS",number=1e10);
write.table(cbind("Gene"=rownames(tt),tt), file="../data/GSE100382_RNAseq_voom_SVA_LPS.txt", row.names=F, sep="\t", quote=F)
tt <- topTable(fit2, coef="TNF.LPS",number=1e10);
write.table(cbind("Gene"=rownames(tt),tt), file="../data/GSE100382_RNAseq_voom_SVA_TNF-LPS.txt", row.names=F, sep="\t", quote=F)
tt <- topTable(fit2, coef="IFN.TNF",number=1e10);
write.table(cbind("Gene"=rownames(tt),tt), file="../data/GSE100382_RNAseq_voom_SVA_TNF-IFN.txt", row.names=F, sep="\t", quote=F)

