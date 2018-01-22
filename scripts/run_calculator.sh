#!/bin/sh

#PBS -l select=1:ncpus=1:mem=2gb:pcmem=6gb
#PBS -l walltime=01:00:00
#PBS -l place=free:shared

cd $OUT_DIR

module load perl
module load python

RUN="$WORKER_DIR/calculator.pl"
perl $RUN $NB_READ $PROFILE

RUN2="$WORKER_DIR/gaussian.py"
python $RUN2 -n $NB_READ -o $OUT_DIR
