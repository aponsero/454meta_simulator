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
    else
       echo Problem submitting job. Job terminated.
       exit 1
    fi
