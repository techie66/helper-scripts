#!/bin/bash
LOG="handbrake.log"
INPUT_DIR=$1
echo "Input Directory = $INPUT_DIR" 2>&1 | tee -a $LOG
FINAL_FILE=$2
echo "Final Filename = $FINAL_FILE" 2>&1 | tee -a $LOG

#Check for spaces
# if spaces exist, replace with _ for working name
# else, add '1' to file for working filename
case "$FINAL_FILE" in
    *\ * )
        OUTPUT_FILE=.$(echo $FINAL_FILE | sed -e 's/\ /_/g')
        ;;
    *)
        OUTPUT_FILE=."$FINAL_FILE"1
        ;;
esac

# shift twice to remove first two args.
# pass rest to Handbrake directly
shift
shift
echo "Intermediate Filename = $OUTPUT_FILE" 2>&1 | tee -a $LOG

# actually do encoding
HandBrakeCLI --native-language eng --subtitle scan,1 --subtitle-forced 1 --quality 21 --format mkv --input "$INPUT_DIR" --encoder x264 --aencoder copy --audio-copy-mask dtshd,dts,ac3 --audio-fallback ffac3 --output ~/Videos/$OUTPUT_FILE "$@" 2>&1 | tee -a $LOG
echo HandBrakeCLI --native-language eng --subtitle scan,1 --subtitle-forced --quality 20 --format mkv --input "$INPUT_DIR" --encoder x264 --aencoder copy --audio-copy-mask dtshd,dts,ac3 --audio-fallback ffac3 --output ~/Videos/$OUTPUT_FILE "$@" 2>&1 | tee -a $LOG

# run mkvmerge to build index for seeking
echo mkvmerge ~/Videos/$OUTPUT_FILE -o ~/Videos/"$FINAL_FILE" 2>&1 | tee -a $LOG
mkvmerge ~/Videos/$OUTPUT_FILE -o ~/Videos/"$FINAL_FILE" 2>&1 | tee -a $LOG

# remove working file
echo rm ~/Videos/$OUTPUT_FILE 2>&1 | tee -a $LOG
rm ~/Videos/$OUTPUT_FILE 2>&1 | tee -a $LOG

