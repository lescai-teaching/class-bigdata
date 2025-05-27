
###########################################################
## system installation steps  for Debian / Ubuntu #########
###########################################################

## compared to the google command console
## the VM doesn't have java and other tool
## already setup

### this updates the repositories list
sudo apt-get update

### this installs the tools we need
sudo apt-get install -y \
    git \
	default-jdk \
    screen



## only after these tools are installed
## we can install nextflow as well

export NXF_VER=25.04.2
export NXF_MODE=google
mkdir nfbin
cd nfbin
curl https://get.nextflow.io | bash
export PATH=${PATH}:${PWD}

## easiest way is to setup default credentials
## although not the most secure way
gcloud auth application-default login

### alternatively, you can use a service account that's been created for you
### the following assumes the credentials have been previously saved
### in a key with a name of your choice

export GOOGLE_APPLICATION_CREDENTIALS=/home/YOUR_HOME_FOLDER/NAME-OF-YOUR-KEY.json

## nextflow run . -c ../google.config -profile google
