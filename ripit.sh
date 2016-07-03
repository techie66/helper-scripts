#!/bin/bash

#set -x
#functions to help us out
die() { echo >&2 -e "\nERROR: $@\n"; exit 1; }
run() { "$@" 2>&1 | tee -a $LOG; code=${PIPESTATUS[0]}; if [ $code -ne 0 ]; then die "command [$*] failed with error code $code"; else echo [$*]; fi }

#Configuration Paramenters
LOG="handbrake.log"
_default_title="--main-feature"
_subtitle="--subtitle 1,scan"
_native_lang="eng"
_format="--format mkv"
_video_dir="~/Videos"
debug=0

################################################################################
# eval _video_dir to expand things like ~/
eval _video_dir=$_video_dir

INPUT_DIR=$1
echo "Input Directory = $INPUT_DIR" 2>&1 | tee -a $LOG
FINAL_FILE=$2
_final_path_file="${_video_dir}/$FINAL_FILE"
echo "Final Filename = $_final_path_file" 2>&1 | tee -a $LOG

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
_intermediate_file="${_video_dir}/${OUTPUT_FILE}"
echo "Intermediate Filename = $_intermediate_file" 2>&1 | tee -a $LOG
if [ $debug -eq 1 ]
then
	echo "Press (Enter) to continue or ^C to exit"
	read $tmp
fi

# modify options based off user specified options
if [[ $@ =~ "-t" ]] || [[ $@ =~ "--title" ]]
then
	_default_title=""
fi

if [[ $@ =~ "-s" ]] || [[ $@ =~ "--subtitle" ]]
then
	_subtitle=""
fi

if [[ $@ =~ "-f" ]] || [[ $@ =~ "--format" ]]
then
	_format=""
fi


#Actually run the command
run HandBrakeCLI $_default_title --native-language $_native_lang --native-dub $_subtitle --quality 21 $_format --input "$INPUT_DIR" --encoder x264 --aencoder copy --audio-copy-mask dtshd,dts,ac3 --audio-fallback ffac3 --output $_intermediate_file "$@"

# run mkvmerge to build index for seeking
run mkvmerge "$_intermediate_file" -o "$_final_path_file"

# remove working file
run rm "$_intermediate_file"

