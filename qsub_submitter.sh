CTRL_ARG=/fs/project/PAS1405/General/Kimmel_Chris/f1_ssfast5s_4500
CTRL_ARG+=" /fs/project/PAS1405/General/Kimmel_Chris/f2_ssfast5s_4500"
EXP_ARG=/users/PAS1405/kimmel/resampling_experiment_2/experimental
NUM_ARG_LIST="20 30"
REF_ARG=/fs/project/PAS1405/General/Kimmel_Chris/RNA_section__454_9627.fa
WORK_ARG=/users/PAS1405/kimmel/resamp3

for num_arg in $NUM_ARG_LIST
do
    RANDOM_ID=${RANDOM}${RANDOM} # Consider moving this outside the loop
    JOB_FILE=${num_arg}_${RANDOM_ID}

    echo "cd /users/PAS1405/kimmel/resamp3" > ${JOB_FILE}
    echo "source resamp3.sh \"${CTRL_ARG}\" ${EXP_ARG} ${num_arg} ${REF_ARG} ${WORK_ARG}" \
        >> ${JOB_FILE}
    qsub -l walltime=2:00:00,nodes=1:ppn=28 -j oe \
        -N ${JOB_FILE} -o logs/${JOB_FILE}.output ${JOB_FILE}

    rm $JOB_FILE
done
