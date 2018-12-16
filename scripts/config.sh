export CWD=$PWD
# where programs are
export BIN_DIR="/rsgrps/bhurwitz/hurwitzlab/bin"
# user configs
export OUT_DIR="/rsgrps/bhurwitz/alise/my_scripts/454meta_simulator/test_pipeline"
export NB_READ=100000
export PROFILE="/rsgrps/bhurwitz/alise/my_scripts/454meta_simulator/test_pipeline/test_uniq.txt"
export DB_DIR="/rsgrps/bhurwitz/alise/my_scripts/454meta_simulator/test_pipeline/ref"
export MODEL_CHOICE=3 #Choose error model 1, 2 or 3
# scripts configs
export SCRIPT_DIR="$PWD/scripts"
export WORKER_DIR="$SCRIPT_DIR/workers"
# user info
export MAIL_USER="aponsero@email.arizona.edu"
export MAIL_TYPE="bea"
export GROUP="bhurwitz"
export QUEUE="standard"


#
# --------------------------------------------------
function init_dir {
    for dir in $*; do
        if [ -d "$dir" ]; then
            rm -rf $dir/*
        else
            mkdir -p "$dir"
        fi
    done
}

# --------------------------------------------------
function lc() {
    wc -l $1 | cut -d ' ' -f 1
}
