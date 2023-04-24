# Job 1 Solution

## Create bash script

First we create a bash script which will look like this (remember, has to accept as an argument the file to select from):

```bash
#!/bin/bash
input=$1

grep "cat2" ${input} >results.txt

```

We can write our script using:

```bash
vim select_script.sh
```


Now that we have the bash script we can create our job script


## Sbatch Job Script

This will be very simple and look like this:

```bash
#!/bin/bash
#SBATCH -c 1
#SBATCH --mem 1G
#SBATCH -t 00:10:00
#SBATCH -p short

script=$1
filesource=$2

bash ${script} ${filesource}
```

we can write our script using the command 

```bash
vim run_script.sh
```

and then run it with:


```bash
sbatch run_script.sh `pwd`/select_script.sh `pwd`/records.txt
```