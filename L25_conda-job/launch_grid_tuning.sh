#!/bin/sh
#SBATCH -c 4
#SBATCH --mem 10G
#SBATCH -t 1:00:00
#SBATCH --job-name tuningFL
#SBATCH -p short

echo "loading module anaconda"
date

module load anaconda3-2023.03

echo "loading conda environment"
conda activate parallel-modelling

echo "launching R script"
date
Rscript parallel_grid_tuning.R

echo "job completed"
date