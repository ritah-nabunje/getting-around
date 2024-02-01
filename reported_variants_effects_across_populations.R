# Look up reported variants in all populations summary statistics
# Plot effects within the different populations if they are present in at least 2.

# set workding directory
setwd("/link/to/dir")

# list of reported variants
reported<-read.delim("/link/to/reported_variants.txt", header = TRUE, sep = "\t") 
# keep the rsid and gene (variant Annotation)
varAnn <- reported[, c("rsid", "gene")] 

# using summary statistics filtered for only the reported variants
# AFR summary statistics
afr <- read.csv("afr_sumstats_reportedVars.txt", sep="", header=FALSE)
# add column names
colnames(afr)<- c("MARKER","Allele1","Allele2","Freq1","FreqSE","MinFreq","MaxFreq","beta","se","p","Direction","studies","chromosome","position","rsid")
# keep the required cols
afr2 <- afr[,c("rsid","beta", "se", "p")]
# specify population group
afr2$group <- "AFR"
# Add the gene column 
afr3 <-left_join(afr2,varAnn)
afr4 <- afr3 %>% filter(rsid %in% reported$rsid)
afr4$varloc <- paste(afr4$rsid, paste("(", afr4$gene, ")", sep = ""), sep = " ") # to have varloc as => "rsid (gene)"

# EAS summary statistics
eas <- read.csv("eas_sumstats_reportedVars.txt", sep="", header=FALSE)
# add column names
colnames(eas)<- c("MARKER","Allele1","Allele2","Freq1","FreqSE","MinFreq","MaxFreq","beta","se","p","Direction","studies","chromosome","position","rsid")
# keep the required cols
eas2 <- eas[,c("rsid","beta", "se", "p")]
# specify population group
eas2$group <- "EAS"
# Add the gene column 
eas3<- left_join(eas2, varAnn)
eas4 <- eas3 %>% filter(rsid %in% reported$rsid)
eas4$varloc <- paste(eas4$rsid, paste("(", eas4$gene, ")", sep = ""), sep = " ")

# EUR summary statistics
eur <- read.csv("eur_sumstats_reportedVars.txt", sep="", header=FALSE)
# add column names
colnames(eur)<- c("marker","rsid","chromosome","position","effect_allele","non_effect_allele","eaf","FreqSE","MinFreq","MaxFreq","beta","se","p","Direction","studies")
# keep the required cols
eur2<- eur[,c("rsid","beta", "se", "p")]
# specify population group
eur2$group <- "EUR"
# Add the gene column 
eur3<- left_join(eur2, varAnn)
eur4<- eur3 %>% filter(rsid %in% reported$rsid)
eur4$varloc <- paste(eur4$rsid, paste("(", eur4$gene, ")", sep = ""), sep = " ")

#========================Prepare to plot==================
library(dplyr)
library(ggplot2)

# Combine data frames for all groups
all_groups <- rbind(eur4, eas4, afr4)
all_groups$varloc <- factor(all_groups$varloc)

# keep variants in at least 2 populations
id_counts <- table(all_groups$rsid)
ids_at_least_two <- names(id_counts[id_counts >= 2])
all_groups2 <- all_groups[all_groups$rsid %in% ids_at_least_two, ]

#==============plot using ggforestplot=================
library(ggforestplot)
forestplot(
  df = all_groups2,
  name=varloc,
  estimate = beta,
  logodds = FALSE,
  colour = group,
  xlab = "Log Odds Ratio"
)
ggsave("reportedVars2.png", width=8, height=4)
