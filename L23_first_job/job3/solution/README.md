# Job3 Exercise Solution


The script simply has to echo a few information, and it will look like this

```bash
#!/bin/bash
#SBATCH -c 1
#SBATCH --mem 1G
#SBATCH -t 00:10:00
#SBATCH -p short

echo "job starts at:"
date

echo "Hello World!" >hello_word.txt

echo "job ends at:"
date
```

One would write the job into a hello world script:

```bash
vim hello_world.sh
```

And however, in order to output a custom log file with the job id as part of the name one would launch as:

```bash
sbatch -o "hello_log_%j.log" hello_world.sh
```

Now one would have as a result something like:

```bash
hello_log_16131.log
```
and if you cat the file

```bash
[stdtest@frontend test_folder]$ cat hello_log_16131.log 
job starts at:
Mon Apr 24 16:42:30 CEST 2023
job ends at:
Mon Apr 24 16:42:30 CEST 2023
```