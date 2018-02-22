#!/bin/sh

#PBS -l select=1:ncpus=1:mem=2gb:pcmem=6gb
#PBS -l walltime=01:00:00
#PBS -l place=free:shared

cd $OUT_DIR
OUTPUTFILE="$OUT_DIR/artificial_454.fna"

find . -type f -name "err_*" -exec cat {} + >> $OUTPUTFILE
 

