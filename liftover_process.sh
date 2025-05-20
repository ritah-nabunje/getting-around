#!/bin/bash

# liftover b37 (hg19) to b38 (hg38)

# edit here
B37_FILES="/path/to/b37/plink/bfiles"
NAME="choosen_name"
WORKING_DIR="/path/to/working/dir"

cd $WORKING_DIR

# first remove duplicated variants if any
module load plink2
plink2 --bfile $B37_FILES \
	--rm-dup exclude-all \
	--make-bed --out ${NAME}_nodups

module load R
#=================== Before Liftover====================
# prepare bed (chr, chromstart, chromend, rsid) file from bim 
Rscript - <<EOF
# Prepare a BED file from .bim for liftover

library(data.table)

# Disable scientific notation for large numbers
options(scipen=999)

# BIM file 
b37_bim <- paste0("$NAME","_nodups.bim")

# Read the BIM file
bimfile <- fread(b37_bim, header = FALSE)

# Ensure the relevant columns are numeric
bimfile[, V1 := as.numeric(V1)] # chr
bimfile[, V4 := as.numeric(V4)] # pos

# Manipulate to create the BED file required for liftover [chr, start, end, rsid (ps, chr is as chr1, chr2)]
bed <- bimfile[, .(chr = paste0("chr", V1), start = V4, end = V4 + 1, rsid = V2)]

# Write the BED file
write.table(bed, "b37_coordinates.bed", quote = FALSE, row.names = FALSE, col.names = FALSE)
EOF

# ======================= lift over 1000 GP b38 to b37 coordinates
/path/to/liftOver b37_coordinates.bed /path/to/hg19ToHg38.over.chain b38_coordinates.bed unlifted.bed

# ====================== post-liftover R script=======================
# only keep the variants that match chr and rsid in both b38 and b37 files (properly mapped)

Rscript - <<EOF
library(data.table)
library(dplyr)

# Disable scientific notation for large numbers
options(scipen=999)

# b38 co-ordinates
b38bed <- fread("b38_coordinates.bed", header = FALSE)
colnames(b38bed) <- c("chr", "start", "end", "rsid")

# b37 coordinates
b37bed <- fread("b37_coordinates.bed", header = FALSE)
colnames(b37bed) <- c("chr", "start", "end", "rsid")

# inner join on 'chr' and 'rsid' columns and select columns from b38
merged <- inner_join(b37bed, b38bed, by = c("chr", "rsid")) %>%
          select(chr, start = start.y, end = end.y, rsid)

# keep list of variants that were lifted
lifted <- merged[, "rsid"]
write.table(lifted, "filtered_variants_after_liftover.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

# new positions
new_pos <- merged[, c("rsid", "start")] 
write.table(new_pos, "filtered_variants_after_liftover.pos", quote = FALSE, row.names = FALSE, col.names = FALSE)
EOF

# ==================== extract the lifted variants and update positions ==========================
# make new bfiles with the lifted over variants
# i use plink 1.9 here because i am lazy to find the plink2 version of this.
module load plink
plink --bfile ${NAME}_nodups \
--extract filtered_variants_after_liftover.txt \
-update-map filtered_variants_after_liftover.pos \
--allow-no-sex --make-bed --out ${NAME}_b38

# if your variants had rsids, this is the end but, if they had chr:pos:ref:alt for rsid, then you should run the next lines
# module load plink2
# plink2 --bfile ${NAME}_b38 --set-all-var-ids @:#:\$r:\$a --new-id-max-allele-len 50 missing --make-bed --out ${NAME}_b38_lifted

echo "✿❀❁❃❋❀✿ Kiwedde! - means complete but, check if everything went as expected. ✿❀❁❃❋❀✿"
