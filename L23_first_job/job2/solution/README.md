# Solution to Job2 Exercise


## Job Scripts

First of all, let's beging by looking at the jobs scripts.

For the first one, the code is going to be identical to the bash script we've written already:

```bash
#!/bin/bash
#SBATCH -c 1
#SBATCH --mem 1G
#SBATCH -t 00:10:00
#SBATCH -p short
grep "cat2" records.txt >results.txt

```

write this job script using the command:

```bash
vim job01.sh
```


Then create the second script like this one


```bash
#!/bin/bash
#SBATCH -c 1
#SBATCH --mem 1G
#SBATCH -t 00:10:00
#SBATCH -p short

tail -n +2 results.txt | head -n 1 >one_line.txt
```

and write it as well with

```bash
vim job02.sh
```

## Launch with dependencies

The job is only going to last for a few seconds in this case: it is impossible therefore to wait for the job ID to appear at screen and then include this job id in a dependency list.

To do this, we should capture the id in a variable, like this:

```bash
jobid=`sbatch job01.sh | cut -d" " -f 4`
```

And this should be launched together with

```bash
sbatch --depend=afterok:${jobid} job02.sh 
```

By passing them both at the terminal like this:

```bash
jobid=`sbatch job01.sh | cut -d" " -f 4`
sbatch --depend=afterok:${jobid} job02.sh 

```