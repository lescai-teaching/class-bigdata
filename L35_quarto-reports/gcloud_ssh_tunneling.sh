##################################
# this code allows to create an SSH tunnel to the VM running RStudio
# and overcome issues with loading the RStudio interface on certain networks
# it will also allow connecting via SSH to the machine if you don't set the
# port forwarding
# IN ORDER TO RUN THIS CODE YOU NEED TO INSTALL
# gcloud sdk
# https://cloud.google.com/sdk/docs/install
########################################

gcloud compute ssh NAME-OF-YOUR-VM \
    --project=NAME-OF-YOUR-GOOGLE-PROJECT \
    --zone=europe-west4-a \
    -- -NL 12000:localhost:8787