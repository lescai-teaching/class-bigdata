## alternative way to setup the environment using conda
## we use micromamba as in https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html

"${SHELL}" <(curl -L micro.mamba.pm/install.sh)

## then

source ~/.bashrc

micromamba env create -f nextflow_environment.yml
micromamba activate nextflow