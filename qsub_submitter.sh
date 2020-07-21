CTRL_ARG=
EXP_ARG=
NUM_ARG=100
REF_ARG=/fs/project/PAS1405/General/Kimmel_Chris/RNA_section__454_9627.fa
WORK_DIR=/users/PAS1405/kimmel/resamp3

# resamp3.sh is not actually the job that gets submitted via the qsub command to
# the Torque scheduler. Torque allows you to pipe "job scripts" into it.
realjob="cd /users/PAS1405/kimmel/resamp3"
realjob="${realjob}\n`cat resamp3.sh`"
realjob="${realjob} 


echo realjob > qsub -l walltime=2:00:00,nodes=1:ppn=28 -j oe
