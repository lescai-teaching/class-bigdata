#!/bin/bash
#SBATCH --partition short
#SBATCH -D /modify/this/path
#SBATCH -c 1
#SBATCH --mem 4G
#SBATCH -t 00:10:00

echo hello world > result.txt