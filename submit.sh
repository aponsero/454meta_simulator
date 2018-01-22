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

PREV_JOB_ID=""
ARGS="-q $QUEUE -W group_list=$GROUP -M $MAIL_USER -m $MAIL_TYPE"

#
## 01- Run calculator
#

PROG="01-Profile_calculator"
export STDERR_DIR="$SCRIPT_DIR/err/$PROG"
export STDOUT_DIR="$SCRIPT_DIR/out/$PROG"

init_dir "$STDERR_DIR" "$STDOUT_DIR"

echo "launching $SCRIPT_DIR/run_calculator.sh as a simple job."

JOB_ID=`qsub $ARGS -v WORKER_DIR,OUT_DIR,PROFILE,NB_READ,STDERR_DIR,STDOUT_DIR -N run_calculator -e "$STDERR_DIR" -o "$STDOUT_DIR" $SCRIPT_DIR/run_calculator.sh`
    
if [ "${JOB_ID}x" != "x" ]; then
    echo Job: \"$JOB_ID\"
    PREV_JOB_ID=$JOB_ID
    else
       echo Problem submitting job. Job terminated.
       exit 1
    fi
#
## 02- run simulator
#

PROG2="02-simulator"
export STDERR_DIR2="$SCRIPT_DIR/err/$PROG2"
export STDOUT_DIR2="$SCRIPT_DIR/out/$PROG2"


init_dir "$STDERR_DIR2" "$STDOUT_DIR2"

export REPORT="$OUT_DIR/report.log"
export NUM_JOBS=$(lc $PROFILE)

if [ $NUM_JOBS -gt 1 ]; then

    echo " launching $SCRIPT_DIR/run_simulator.sh as an array job : $NUM_JOBS jobs are launched"
    echo "previous job ID $PREV_JOB_ID"

    JOB_ID=`qsub $ARGS -v OUT_DIR,WORKER_DIR,DB_DIR,REPORT,STDERR_DIR2,STDOUT_DIR2 -N run_simulation -e "$STDERR_DIR2" -o "$STDOUT_DIR2" -W depend=afterok:$PREV_JOB_ID -J 1-$NUM_JOBS $SCRIPT_DIR/run_simulator.sh`

    if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
        PREV_JOB_ID=$JOB_ID
    else
        echo Problem submitting job. Job terminated.
        exit 1
   fi

else
        echo "launching $SCRIPT_DIR/run_simulator.sh as unique job."

        JOB_ID=`qsub $ARGS -v WORKER_DIR,DB_DIR,REPORT,STDERR_DIR2,STDOUT_DIR2 -N run_simulation -e "$STDERR_DIR2" -o "$STDOUT_DIR2" -W depend=afterok:$PREV_JOB_ID $SCRIPT_DIR/run_simulator.sh`

        if [ "${JOB_ID}x" != "x" ]; then
             echo Job: \"$JOB_ID\"
             PREV_JOB_ID=$JOB_ID
        else
             echo Problem submitting job. Job terminated.
             exit 1
        fi
fi



