# Job2 Exercise


Write two sbatch scripts:

- the first one runs the same task as in exercise one but the bash command is in the same sbatch script (i.e. does not run another script)
- the second one is a job dependent on the first one, which takes the second line of the resulting file

Please write the scripts without using "sleep" statements.

This means, you should launch the sbatch command at the same time and therefore capture the job ID of the first one in order to launch the second one.