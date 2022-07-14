#!/usr/bin/env bash

set -e
set -u
set -o pipefail

log() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "$(date '+%Y-%m-%dT%H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}
SECONDS=0

stage=-1
stop_stage=1
fs=48000

log "$0 $*"
. utils/parse_options.sh

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;
. ./db.sh || exit 1;

db_root=${JSUT}

train_set=tr_no_dev
train_dev=dev
recog_set=eval1

if [ ${stage} -le -1 ] && [ ${stop_stage} -ge -1 ]; then
    echo "stage -1: Data Download"
    local/download.sh ${db_root}
fi

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    # Initial normalization of the data
    local/data_prep.sh ${db_root}/jsut_ver1.1 data/train ${fs}
    utils/validate_data_dir.sh --no-feats data/train

    # changing the sampling rate option in pitch.conf and fbank.conf
    local/change_sampling_rate.sh ${fs}
fi


#大量データ
if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    # make evaluation and devlopment sets
    utils/subset_data_dir.sh --first data/train 500 data/deveval # get first 500 data from data/train to data/deveval
    utils/subset_data_dir.sh --first data/deveval 250 data/${recog_set} # for eval error, get first 250 data from data/deveval (500 data total)
    utils/subset_data_dir.sh --last data/deveval 250 data/${train_dev} # for dev error, get last 250 data frin data/deveval (500 data total)
    n=$(( $(wc -l < data/train/wav.scp) - 500 ))
    # all last data for training expect the first 500 data which used for data/deveval
    # which means n = all data - 500 (data number in data/deveval)
    utils/subset_data_dir.sh --last data/train ${n} data/${train_set} 
fi

log "Successfully finished. [elapsed=${SECONDS}s]"

#   subset_data_dir.sh
#   echo "Usage:"
#   echo "  subset_data_dir.sh [--speakers|--shortest|--first|--last|--per-spk] <srcdir> <num-utt> <destdir>"
#   echo "  subset_data_dir.sh [--spk-list <speaker-list-file>] <srcdir> <destdir>"
#   echo "  subset_data_dir.sh [--utt-list <utt-list-file>] <srcdir> <destdir>"
#   echo "By default, randomly selects <num-utt> utterances from the data directory."
#   echo "With --speakers, randomly selects enough speakers that we have <num-utt> utterances"
#   echo "With --per-spk, selects <num-utt> utterances per speaker, if available."
#   echo "With --first, selects the first <num-utt> utterances"
#   echo "With --last, selects the last <num-utt> utterances"
#   echo "With --shortest, selects the shortest <num-utt> utterances."
#   echo "With --spk-list, reads the speakers to keep from <speaker-list-file>"
#   echo "With --utt-list, reads the utterances to keep from <utt-list-file>"