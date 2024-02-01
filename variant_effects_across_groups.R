# Comparing effects of significantly associated variants in on ancestry group across others
# Do these variants have similar effects across the ancestry groups?
# Note: This is only for variants present in at least 2 groups.

setwd("/link/to/dir")
library(dplyr)
library(ggplot2)

# summary stats
eas_sum <- read.csv("/link/to/EAS_sumstats.txt", sep = "")
eur_sum <- read.csv("/link/to/EUR_sumstats.txt", sep = "")
afr_sum <- read.csv("AFR_sumstats.txt", sep = "")

#==========================EUR sentinels==================================
eur_sentinels <- read.csv("/link/to/EUR_sentinels.txt", sep="")
## compute OR and 95% CI
eur_sentinels$OR <- exp(eur_sentinels$beta)
eur_sentinels$lowerCI <- exp((eur_sentinels$beta)-(1.96*eur_sentinels$se))
eur_sentinels$upperCI <- exp((eur_sentinels$beta)+(1.96*eur_sentinels$se))
## keep only the required columns
eur_sentinels <- eur_sentinels[, c("rsid","OR", "lowerCI", "upperCI")]
## specify the population/ancestry group
eur_sentinels$group <- "EUR"

# EUR sentinels in other groups
## EUR sentinel variants in EAS summary stats 
eur_in_eas <- eas_sum %>% filter(rsid %in% eur_sentinels$rsid)
## compute OR and 95% CI
eur_in_eas$OR <- exp(eur_in_eas$Effect)
eur_in_eas$lowerCI <- exp((eur_in_eas$Effect)-(1.96*eur_in_eas$StdErr))
eur_in_eas$upperCI <- exp((eur_in_eas$Effect)+(1.96*eur_in_eas$StdErr))
## keep only the required columns
eur_in_eas<- eur_in_eas[, c("rsid","OR", "lowerCI", "upperCI") ]
## specify population group
eur_in_eas$group <- "EAS"

## EUR sentinel variants in AFR summary stats
eur_in_afr <- afr_sum %>% filter(rsid %in% eur_sentinels$rsid)
## compute OR and 95% CI
eur_in_afr$OR <- exp(eur_in_afr$Effect)
eur_in_afr$lowerCI <- exp((eur_in_afr$Effect)-(1.96*eur_in_afr$StdErr))
eur_in_afr$upperCI <- exp((eur_in_afr$Effect)+(1.96*eur_in_afr$StdErr))
## keep only the required columns
eur_in_afr<- eur_in_afr[, c("rsid","OR", "lowerCI", "upperCI") ]
## specify population group
eur_in_afr$group <- "AFR"

## EUR sentinels in all groups
all_eur_sentinels <- rbind(eur_sentinels, eur_in_eas, eur_in_afr)
all_eur_sentinels$rsid <- factor(all_eur_sentinels$rsid)

## Keep the rsids (variants) in at least 2 groups
eurid_counts <- table(all_eur_sentinels$rsid)
eur_in_two <- names(eurid_counts[eurid_counts >= 2])# get varinats in atleast 2 groups
all_eur_sentinels <- all_eur_sentinels[all_eur_sentinels$rsid %in% eur_in_two, ]

# plot to compare effects of EUR sentinels in at least 2 populations
p <- 
  all_eur_sentinels |>
  ggplot(aes(y = rsid, x=log(OR), colour=group)) + 
  geom_point(shape=15, size=1, position = position_dodge(width = 0.75)) +
  geom_linerange(aes(xmin=log(lowerCI), xmax=log(upperCI)), position = position_dodge(width = 0.75))+
  geom_vline(xintercept = 0, linetype="dashed", color = "gray") +
  labs(x="Log Odds Ratio", y="")+
  theme_classic()+
  ggtitle("EUR") 
p
ggsave("EURsentinels.png", width=8, height=4)

#============================EAS sentinels=================================================
eas_sentinels <-read.csv("/link/to/EAS_sentinels.txt", sep="")
## compute OR and 95% CI
eas_sentinels$OR <- exp(eas_sentinels$Effect)
eas_sentinels$lowerCI <- exp((eas_sentinels$Effect)-(1.96*eas_sentinels$StdErr))
eas_sentinels$upperCI <- exp((eas_sentinels$Effect)+(1.96*eas_sentinels$StdErr))
## keep only the required columns
eas_sentinels <- eas_sentinels[, c("rsid","OR", "lowerCI", "upperCI")]
## specify the population/ancestry group
eas_sentinels$group <- "EAS"

## EAS sentinels in other groups
## EAS sentinel variants in EUR summary stats
eas_in_eur <- eur_sum %>% filter(rsid %in% eas_sentinels$rsid)
## compute OR and 95% CI
eas_in_eur$OR <- exp(eas_in_eur$beta)
eas_in_eur$lowerCI <- exp((eas_in_eur$beta)-(1.96*eas_in_eur$se))
eas_in_eur$upperCI <- exp((eas_in_eur$beta)+(1.96*eas_in_eur$se))
## keep only the required columns
eas_in_eur<- eas_in_eur[, c("rsid","OR", "lowerCI", "upperCI") ]
## specify the population/ancestry group
eas_in_eur$group <- "EUR"

## EAS sentinel variants in AFR summary stats
eas_in_afr <- afr_sum %>% filter(rsid %in% eas_sentinels$rsid)
## compute OR and 95% CI
eas_in_afr$OR <- exp(eas_in_afr$Effect)
eas_in_afr$lowerCI <- exp((eas_in_afr$Effect)-(1.96*eas_in_afr$StdErr))
eas_in_afr$upperCI <- exp((eas_in_afr$Effect)+(1.96*eas_in_afr$StdErr))
## keep only the required columns
eas_in_afr<- eas_in_afr[, c("rsid","OR", "lowerCI", "upperCI") 
## specify the population/ancestry group
eas_in_afr$group <- "AFR"

## eas sentinels in all groups
all_eas_sentinels <- rbind(eas_sentinels, eas_in_eur, eas_in_afr)
all_eas_sentinels$rsid <- factor(all_eas_sentinels$rsid)

## Keep the rsids (variants) in at least 2 groups
easid_counts <- table(all_eas_sentinels$rsid)
eas_in_two <- names(easid_counts[easid_counts >= 2]) # rsids in at least 2 groups
all_eas_sentinels <- all_eas_sentinels[all_eas_sentinels$rsid %in% eas_in_two, ]

# plot to compare effects of EAS sentinels in at least 2 populations
p2 <- 
  all_eas_sentinels |>
  ggplot(aes(y = rsid, x=log(OR), colour=group)) + 
  theme_classic()+
  geom_point(shape=15, size=1, position = position_dodge(width = 0.5)) +
  geom_linerange(aes(xmin=log(lowerCI), xmax=log(upperCI)), position = position_dodge(width = 0.5))+
  geom_vline(xintercept = 0, linetype="dashed", color = "gray") +
  labs(x="Log Odds Ratio", y="")+
  ggtitle("EAS")
p2
ggsave("EASsentinels.png", width=8, height=4)

#=================AFR Sentinels===================================
afr_sentinels <-read.csv("/linkt/to/AFR_sentinels.txt", sep="")
## compute OR and 95% CI
afr_sentinels$OR <- exp(afr_sentinels$Effect)
afr_sentinels$lowerCI <- exp((afr_sentinels$Effect)-(1.96*afr_sentinels$StdErr))
afr_sentinels$upperCI <- exp((afr_sentinels$Effect)+(1.96*afr_sentinels$StdErr))
## keep only the required columns
afr_sentinels <- afr_sentinels[, c("rsid","OR", "lowerCI", "upperCI")]
## specify population group
afr_sentinels$group <- "AFR"

# AFR sentinels in other groups
## AFR sentinel variants in EUR summary stats
afr_in_eur <- eur_sum %>% filter(rsid %in% afr_sentinels$rsid)
## compute OR and 95% CI
afr_in_eur$OR <- exp(afr_in_eur$beta)
afr_in_eur$lowerCI <- exp((afr_in_eur$beta)-(1.96*afr_in_eur$se))
afr_in_eur$upperCI <- exp((afr_in_eur$beta)+(1.96*afr_in_eur$se))
## keep only the required columns
afr_in_eur<- afr_in_eur[, c("rsid","OR", "lowerCI", "upperCI") ]
## specify the population/ancestry group
afr_in_eur$group <- "EUR"

## AFR sentinel variants in EAS summary stats
afr_in_eas <- eas_sum %>% filter(rsid %in% afr_sentinels$rsid)
## compute OR and 95% CI
afr_in_eas$OR <- exp(afr_in_eas$Effect)
afr_in_eas$lowerCI <- exp((afr_in_eas$Effect)-(1.96*afr_in_eas$StdErr))
afr_in_eas$upperCI <- exp((afr_in_eas$Effect)+(1.96*afr_in_eas$StdErr))
## keep only the required columns
afr_in_eas<- afr_in_eas[, c("rsid","OR", "lowerCI", "upperCI") ]
## specify the population/ancestry group
afr_in_eas$group <- "EAS"

## AFR sentinels in all groups
all_afr_sentinels <- rbind(afr_sentinels, afr_in_eur, afr_in_eas)
all_afr_sentinels$rsid <- factor(all_afr_sentinels$rsid)

## Keep the rsids (variants) in at least 2 groups
afrid_counts <- table(all_afr_sentinels$rsid)
afr_in_two <- names(afrid_counts[afrid_counts >= 2]) # rsids in at least 2 groups
all_afr_sentinels <- all_afr_sentinels[all_afr_sentinels$rsid %in% afr_in_two, ]

# plot to compare effects of AFR sentinels in at least 2 populations
p3 <- 
  all_afr_sentinels |>
  ggplot(aes(y = rsid, x=log(OR), colour=group)) + 
  theme_classic()+
  geom_point(shape=15, size=1, position = position_dodge(width = 0.5)) +
  geom_linerange(aes(xmin=log(lowerCI), xmax=log(upperCI)), position = position_dodge(width = 0.5))+
  geom_vline(xintercept = 0, linetype="dashed", color = "gray") +
  labs(x="Log Odds Ratio", y="")+
  ggtitle("AFR")
p3
ggsave("AFRsentinels.png", width=8, height=4)

#========================better plots with ggforestplot()================================
# see "plot_variant_effects_across_groups_with_ggforestplot.R"
