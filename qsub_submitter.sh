CTRL_ARG=/fs/project/PAS1405/General/Kimmel_Chris/f1_ssfast5s_4500
CTRL_ARG+=" /fs/project/PAS1405/General/Kimmel_Chris/f2_ssfast5s_4500"
EXP_ARG=/users/PAS1405/kimmel/resampling_experiment_2/experimental
REF_ARG=/fs/project/PAS1405/General/Kimmel_Chris/RNA_section__454_9627.fa
WORK_ARG=/users/PAS1405/kimmel/resamp3

# NOTE. Originally I ran this script with minimum control depth 100.
# ... later I decided I wanted results for 10, 20, ..., 90 too, but it wasn't
# ... worth re-running the whole thing.
# ALSO NOTE: The run with "100000 reads" really just takes every available read
# for num_arg in {100..900..100} {1000..9000..1000} {10000..50000..10000} 100000
for num_arg in {10..90..10}
do
    RANDOM_ID=${RANDOM}${RANDOM} # Consider moving this outside the loop
    JOB_FILE=${num_arg}_${RANDOM_ID}

    echo "cd /users/PAS1405/kimmel/resamp3" > ${JOB_FILE}
    echo "source resamp3.sh \"${CTRL_ARG}\" ${EXP_ARG} ${num_arg} ${REF_ARG} ${WORK_ARG}" \
        >> ${JOB_FILE}
    qsub -l walltime=48:00:00,nodes=1:ppn=28 -j oe \
        -N ${JOB_FILE} -o logs/${JOB_FILE}.output ${JOB_FILE}

    rm $JOB_FILE
done
