#!/bin/bash
# [add job scheduler details here]

# download 1000 genomes genotypes (probably for the millionth time)
cd /your/dir/

# Autosomes only chr1..22 
# [i have no justification for this]
# From https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/
# I choose the high-coverage Illumina integrated phased panel which
# includes filtered SNV, INDEL, and SV (large deletions (DEL), insertions (INS), duplications (DUP), and
# inversions(INV)) variant calls across 3,202 1kGP samples.
for chr in {1..22}
do 
	wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20220422_3202_phased_SNV_INDEL_SV/1kGP_high_coverage_Illumina.chr${chr}.filtered.SNV_INDEL_SV_phased_panel.vcf.gz
done

# vcf.gz to plink
module load plink2
for chr in {1..22}
do 
	plink2 --vcf 1kGP_high_coverage_Illumina.chr${chr}.filtered.SNV_INDEL_SV_phased_panel.vcf.gz --make-bed --out 1kGP_chr${chr}
done

## merge the chr files
# prepare list of chr2..22
echo -e 1kGP_chr{2..22}'\n' > list_to_merge

## merge the list to chr1
# (I use plink1 here)
plink \
    --bfile 1kGP_chr1 \
    --merge-list list_to_merge \
	--allow-no-sex \
	--make-bed \
    --out 1kGP_allchr
