# similar to 
setwd("/link/to/dir")
library(dplyr)
library(ggplot2)
library(ggforestplot)

# sum stats
eas_sum <- read.csv("/link/to/EAS_sumstats.txt", sep = "")
eur_sum <- read.csv("/link/to/EUR_sumstats.txt", sep = "")
afr_sum <- read.csv("/link/to/AFR_sumstats.txt", sep = "")

#==========================EUR sentinels==================================
eur_sentinels <- read.csv("/link/to/EUR_sentinels.txt", sep="")
## keep required columns
eur_sentinels <- eur_sentinels[, c("rsid","beta", "se", "p")]
## specify population group
eur_sentinels$group <- "EUR"

# EUR sentinels in other groups
## EUR sentinel variants in EAS
eur_in_eas <- eas_sum %>% filter(rsid %in% eur_sentinels$rsid)
## keep required columns
eur_in_eas<- eur_in_eas[, c("rsid","Effect", "StdErr", "Pvalue") ]
## match column names
colnames(eur_in_eas) <- c("rsid","beta", "se", "p")
## specify population group
eur_in_eas$group <- "EAS"

## EUR sentinel variants in AFR
eur_in_afr <- afr_sum %>% filter(rsid %in% eur_sentinels$rsid)
## keep required columns
eur_in_afr<- eur_in_afr[, c("rsid","Effect", "StdErr", "Pvalue") ]
## match column names
colnames(eur_in_afr) <- c("rsid","beta", "se", "p")
## specify population group
eur_in_afr$group <- "AFR"

## EUR sentinels in all groups 
all_eur_sentinels <- rbind(eur_sentinels, eur_in_eas, eur_in_afr)
all_eur_sentinels$rsid <- factor(all_eur_sentinels$rsid)

## keep the variants rsids in at least 2 groups
eurid_counts <- table(all_eur_sentinels$rsid)
eur_in_two <- names(eurid_counts[eurid_counts >= 2])# get varinats in atleast 2 groups
all_eur_sentinels <- all_eur_sentinels[all_eur_sentinels$rsid %in% eur_in_two, ]

#==============plot using ggforestplot=================
forestplot(
  df = all_eur_sentinels,
  name=rsid,
  estimate = beta,
  logodds = FALSE,
  colour = group,
  xlab = "Log Odds Ratio",
  title="EUR"
)
ggsave("EURsentinels2.png", width=8, height=4)
