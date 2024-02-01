# This follows testing a PRS derived from selected reported variants using PRSice2
# Utilising PRSice output
# The PRS was tested in 3 populations i.e EUR, EAS, and AFR

setwd("/link/to/prs/dir")

#install.packages("pROC")
library(pROC)
library(ggplot2)
library(dplyr)

# ===========================EAS------------------------
# indivdual PRS scores for EAS
eas_best <- read.delim("eas/eas.best", header = TRUE, sep = "")
# individuals phenotype 
eas_pheno <- read.table("EAS.pheno", header = TRUE)
# merge phenotype and PRS scores for each individual
eas_results <- merge(eas_best, eas_pheno, by = c("FID", "IID"), all = TRUE)
# compute and plot ROC
easroc_curve <- roc(eas_results$pheno, eas_results$PRS)
plot(easroc_curve, main = "EAS ROC Curve", col = "blue", lwd = 2)
# Calculate AUC
easroc_auc <- auc(easroc_curve)
cat("EAS AUC:", easroc_auc, "\n")

# ========================AFR-----------------------------
# indivdual PRS scores for AFR
afr_best <- read.delim("/scratch/gen1/rn180/respiratory_fibrosis/prs/afr/afr.best", header = TRUE, sep = "")
# individuals phenotype
afr_pheno <- read.table("AFR.pheno", header = TRUE)
# merge phenotype and PRS scores for each individual
afr_results <- merge(afr_best, afr_pheno, by = c("FID", "IID"), all = TRUE)
# compute and plot ROC
afrroc_curve <- roc(afr_results$pheno, afr_results$PRS)
plot(afrroc_curve, main = "AFR ROC Curve", col = "blue", lwd = 2)
# Calculate AUC
afrroc_auc <- auc(afrroc_curve)
cat("AFR AUC:", afrroc_auc, "\n")

# =====================EUR -----------------------
# indivdual PRS scores for EUR
eur_best <- read.delim("/scratch/gen1/rn180/respiratory_fibrosis/prs/eur/eur.best", header = TRUE, sep = "")
# individuals phenotype
eur_pheno <- read.table("EUR.pheno", header = TRUE)
# merge phenotype and PRS scores for each individual
eur_results <- merge(eur_best, eur_pheno, by = c("FID", "IID"), all = TRUE)
# compute and plot ROC
eurroc_curve <- roc(eur_results$pheno, eur_results$PRS)
plot(eurroc_curve, main = "EUR ROC Curve", col = "blue", lwd = 2)
# Calculate AUC
eurroc_auc <- auc(eurroc_curve)
cat("EUR AUC:", eurroc_auc, "\n")

# =================plotting a combined ROC- plot===================
# prep plotting device specifications
png("roc_plot.png", width = 5, height = 5, units = "in", res = 300)

# Plot the 3 ROC curves on one 
plot(easroc_curve, col = "green", main = "ROC Curves", lwd = 1)
lines(afrroc_curve, col = "red", lwd = 1)
lines(eurroc_curve, col = "blue", lwd = 1)

# Add AUC values as text annotations
text(0.85, 1, paste("AUC EAS:", round(easroc_auc, 2)))
text(0.85, 0.95, paste("AUC AFR:", round(afrroc_auc, 2)))
text(0.85, 0.9, paste("AUC EUR:", round(eurroc_auc, 2)))

# Add legend
legend("bottomright", legend = c("EAS", "AFR", "EUR"), col = c("green", "red", "blue"), lwd = 1)
# Save the plot
dev.off()

#====================================plot PRS.R2=====================
# get PRS.R2 for all the populations
eas_r2 <- read.delim("eas/eas.prsice", header = TRUE, sep = "")
afr_r2 <- read.delim("afr/afr.prsice", header = TRUE, sep = "")
eur_r2 <- read.delim("eur/eur.prsice", header = TRUE, sep = "")
# combine them while specifying the run/population
combined_result <- bind_rows(
  mutate(eas_r2, Run = "EAS"),
  mutate(afr_r2, Run = "AFR"),
  mutate(eur_r2, Run = "EUR")
)
# plot
ggplot(combined_result, aes(x = Run, y = R2)) +
  geom_bar(stat = "identity", fill = "dodgerblue", width = 0.5) +
  geom_text(aes(label = sprintf("p = %.3f", P), y = R2), vjust = -0.5, size = 3)+
  labs(x="Population", y =expression(paste("PRS model fit: ", R^2))) +
  theme_classic()
ggsave("PRS_R2_all.png", width=4, height=4)
