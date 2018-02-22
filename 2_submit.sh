#!/bin/sh
set -u
#
# Checking args
#

source scripts/config.sh

if [[ ! -f "$PROFILE" ]]; then
    echo "$PROFILE does not exist. Please provide the path for a metagenome profile. Job terminated."
    exit 1
fi

if [[ ! -d "$DB_DIR" ]]; then
    echo "$DB_DIR does not exist. Please provide the path for the folder containing the reference genomes. Job terminated."
    exit 1
fi

if [[ ! -d "$OUT_DIR" ]]; then
    echo "$OUT_DIR does not exist. The folder was created."
    mkdir $OUT_DIR
fi

#
# Job submission
#

ARGS="-q $QUEUE -W group_list=$GROUP -M $MAIL_USER -m $MAIL_TYPE"

#
## 02- run simulator
#

PROG2="02-simulator"
export STDERR_DIR2="$SCRIPT_DIR/err/$PROG2"
export STDOUT_DIR2="$SCRIPT_DIR/out/$PROG2"


init_dir "$STDERR_DIR2" "$STDOUT_DIR2"

export REPORT="$OUT_DIR/report.log"
export NUM_JOBS=$(lc $REPORT)
    echo "Error model choice : $MODEL_CHOICE"

if [ $NUM_JOBS -gt 1 ]; then

    echo " launching $SCRIPT_DIR/run_simulator.sh as an array job : $NUM_JOBS jobs are launched"

    JOB_ID=`qsub $ARGS -v MODEL_CHOICE,OUT_DIR,WORKER_DIR,DB_DIR,REPORT,STDERR_DIR2,STDOUT_DIR2 -N run_simulation -e "$STDERR_DIR2" -o "$STDOUT_DIR2" -J 1-$NUM_JOBS $SCRIPT_DIR/run_simulator.sh`

    if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
        PREV_JOB_ID=$JOB_ID
    else
        echo Problem submitting job. Job terminated.
        exit 1
   fi

else
        echo "launching $SCRIPT_DIR/run_simulator.sh as unique job."

        JOB_ID=`qsub $ARGS -v MODEL_CHOICE,WORKER_DIR,DB_DIR,REPORT,STDERR_DIR2,STDOUT_DIR2 -N run_simulation -e "$STDERR_DIR2" -o "$STDOUT_DIR2" $SCRIPT_DIR/run_simulator.sh`

        if [ "${JOB_ID}x" != "x" ]; then
             echo Job: \"$JOB_ID\"
             PREV_JOB_ID=$JOB_ID
        else
             echo Problem submitting job. Job terminated.
             exit 1
        fi
fi


#
## 03- run merge
#

PROG3="03-merge"
export STDERR_DIR3="$SCRIPT_DIR/err/$PROG3"
export STDOUT_DIR3="$SCRIPT_DIR/out/$PROG3"


init_dir "$STDERR_DIR3" "$STDOUT_DIR3"


echo " launching $SCRIPT_DIR/run_merge.sh as an unique job"

JOB_ID=`qsub $ARGS -v OUT_DIR,STDERR_DIR3,STDOUT_DIR3 -N run_simulation -e "$STDERR_DIR3" -o "$STDOUT_DIR3" -W depend=afterok:$PREV_JOB_ID $SCRIPT_DIR/run_merge.sh`

if [ "${JOB_ID}x" != "x" ]; then
    echo Job: \"$JOB_ID\"
else
    echo Problem submitting job. Job terminated.
    exit 1
fi

