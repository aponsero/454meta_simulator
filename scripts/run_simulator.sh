#/bin/sh

#PBS -l select=1:ncpus=1:mem=2gb:pcmem=6gb
#PBS -l walltime=01:00:00
#PBS -l place=free:shared

module load perl

cd $OUT_DIR
echo "Array launch nb ${PBS_ARRAY_INDEX}"

LINE=`head -n +${PBS_ARRAY_INDEX} $REPORT | tail -n 1`

arrIN=(${LINE//;/ })
export NAME=${arrIN[0]}
export NB_READ=${arrIN[2]} 
export FILE="$DB_DIR/$NAME"

export GAUSS_LINE=${arrIN[3]}
export NB_CONTIG=$(grep -c ">" $FILE)

echo "nb of sequences in the file = $NB_CONTIG"

RUN="$WORKER_DIR/model${MODEL_CHOICE}_simulator.pl"


perl $RUN $NAME $NB_READ $NB_CONTIG $DB_DIR $GAUSS_LINE
