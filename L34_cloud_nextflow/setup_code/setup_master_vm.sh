
###############################################
## system installation steps ##################
###############################################

## compared to the google command console
## the VM doesn't have java and other tool
## already setup


sudo yum install -y git
sudo yum install -y java-11-openjdk-devel
sudo yum install -y screen


## only after these tools are installed
## we can install nextflow as well

export NXF_VER=24.04.1
export NXF_MODE=google
mkdir nfbin
cd nfbin
curl https://get.nextflow.io | bash
export PATH=${PATH}:${PWD}

### the following assumes the credentials have been previously saved
### in a key with a name of your choice

export GOOGLE_APPLICATION_CREDENTIALS=/home/YOUR_HOME_FOLDER/NAME-OF-YOUR-KEY.json

## nextflow run . -c ../google.config -profile gls
