#!/bin/bash
LOG="handbrake.log"
INPUT_DIR=$1
START_EP=$2
NUM_EP=$3
BASENAME=$4
#Check for spaces
# if spaces exist, replace with _ for working name
# else, add '1' to file for working filename
#echo "BASENAME=$BASENAME"
case "$BASENAME" in
    *\ * )
        OUTPUT_FILE=.$(echo $BASENAME | sed -e 's/\ /_/g')
        ;;
    *)
        OUTPUT_FILE=."$BASENAME"
        ;;
esac
#echo "OUTPUT=$OUTPUT_FILE"
# shift four to remove first four args.
# pass rest to Handbrake directly
shift
shift
shift
shift

for (( i=1; i<=$NUM_EP; i++ ))
do
  let "CURR_EP=$START_EP + $i - 1"
  temp=${OUTPUT_FILE}_${CURR_EP}.mkv
  fin=${BASENAME}_${CURR_EP}.mkv
  HandBrakeCLI --quality 25 --format mkv --input "$INPUT_DIR" -t $i --encoder x264 --aencoder copy --audio-copy-mask dtshd,dts,ac3 --audio-fallback lame --output ./$temp "$@" 2>&1 | tee -a $LOG
  mkvmerge ./$temp -o ./"$fin" 2>&1 | tee -a $LOG
  rm ./$temp 2>&1 | tee -a $LOG
done

