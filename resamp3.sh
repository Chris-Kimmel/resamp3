# This script copies a random sample of control fast5 files from one directory
# into a temporary directory. It also copies all the experimental fast5s from
# another temporary directory, then resquiggles both new directories (control
# and experimental) before running "tombo detect_modifications
# model_sample_compare" to compute per-read statistics for the experimental
# fast5s. Finally, it combines each of the two new fast5 directories into a
# single file to prevent overuse of the file-number quota while preserving raw
# data (just in case). The script does all this work in a new directory it
# creates at the very beginning.

# This script takes four command-line arguments (must be run with "source")

# $ source resamp3.sh [CTRL_ARG] [EXP_ARG] [NUM_ARG] [REF_ARG] [WORK_DIR]

# CTRL_ARG (absolute path to a directory) contains control fast5s to be
# randomly sampled and copied

# EXP_ARG (absolute path to a directory) contains experimental fast5s, all of
# which will be copied

# NUM_ARG (positive integer) is the number of files to copy from CTRL_ARG

# REF_ARG (absolute path to FASTA file) is a path to the FASTA file to use as a
# reference during the resquiggling step

# WORK_DIR (basename of a directory) tells the script what to call the directory
# that it will store all its data and results in. The current working directory
# must not already contain a directory of this name.

conda activate tombo2 # Change conda environment name to match your own
trap 'conda deactivate tombo2' EXIT # Ensures deactivation no matter what
# Really it shouldn't matter that the environment deactivates, since this script
# is intended to run as a qsub job

set -u # Fail upon failed parameter expansion (i.e., undefined variable)
set -x # Print every command to stdout before running it

CTRL_ARG=$1
EXP_ARG=$2
NUM_ARG=$3
REF_ARG=$4
WORK_DIR=$5

if [ -e "$WORK_DIR" ]
then
    echo "Failure: WORK_DIR already exists:"
    echo "$WORK_DIR"
    exit 1
fi

mkdir "$WORK_DIR"
mkdir "${WORK_DIR}"/ctrl
mkdir "${WORK_DIR}"/exp

# List files from $EXP_ARG and copy in chunks of 500
find "$EXP_ARG" -maxdepth 1 -mindepth 1 -printf '%P\n' | \
    xargs -n 500 -I '{}' cp -t "$WORK_DIR"/exp "${EXP_DIR}"/'{}'
# Same, but randomly choose only NUM_ARG to copy
find "$CTRL_ARG" -maxdepth 1 -mindepth 1 -printf '%P\n' | \
    shuf -n "$NUM_ARG" | \
    xargs -n 500 -I '{}' cp -t "$WORK_DIR"/ctrl "${CTRL_ARG}"/'{}'

# To be in same directory as fast5 basedirs
cd "$WORK_DIR" || EXIT

# I believe we need exp and ctrl to be resquiggled to corrected groups with the
# same name, otherwise "tombo detect_modifications model_sample_compare" might
# not compare the right corrected groups. (Tombo's choice of which corrected
# group to read in the absence of the --corrected-group option is undocumented.)
# That's why I added the --corrected-group and --overwrite options.
#CORR_GRP
NUM_PROC=28 # Number of processes to use during Tombo resquiggling
for which in exp ctrl
do
    tombo resquiggle "$which" "$REF_ARG" \
        --processes "$NUM_PROC" \
        --q-score 7 \
        --corrected-group "$CORR_GRP" \
        --overwrite \
        --ignore-read-locks
done

# Resquiggling two directories would be faster if they were resquiggled in
# parallel, rather than in series, but I assume the experimental sample is
# rather small compared to the control sample:

EXT='' # To help distinguish output files from runs with different parameters
detect_modifications model_sample_compare \
    --fast5-basedirs exp \
    --control-fast5-basedirs ctrl \
    --statistics-file-basename "sf_${NUM_ARG}${EXT}" \
    --per-read-statistics-basename "prs_${NUM_ARG}${EXT}" \
    --sample-only-estimates \
    --fishers-method-context 3 \
    --corrected-group "${CORR_GRP}"

for which in exp ctrl
do
    tar -cf ${which}.tar ${which}/*
    rm -r $which
done

cd ..

exit 0 # Exit with success
