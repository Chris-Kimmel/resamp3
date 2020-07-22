CTRL_ARG=/fs/project/PAS1405/General/Kimmel_Chris/f1_ssfast5s_4500
CTRL_ARG+=" /fs/project/PAS1405/General/Kimmel_Chris/f2_ssfast5s_4500"
EXP_ARG=/users/PAS1405/kimmel/resampling_experiment_2/experimental
NUM_ARG_LIST="20 30"
REF_ARG=/fs/project/PAS1405/General/Kimmel_Chris/RNA_section__454_9627.fa
WORK_ARG=/users/PAS1405/kimmel/resamp3

for NUM_ARG in NUM_ARG_LIST:
do
    JOB_FILE=${RANDOM}${RANDOM}
    echo "cd /users/PAS1405/kimmel/resamp3" > ${JOB_FILE}
    echo "source resamp3.sh \"${CTRL_ARG}\" ${EXP_ARG} ${NUM_ARG} ${REF_ARG} ${WORK_ARG}" \
        >> ${JOB_FILE}
    qsub -l walltime=2:00:00,nodes=1:ppn=28 -j oe -N ${NUM_ARG}_${JOB_FILE} ${JOB_FILE}
    echo "rm $JOB_FILE" # TODO: Remove echo and quotes
done
