    #!/bin/bash
    # ———-
    # This script takes a MP4 or MKV file with an AAC audio track as input and
    #Â Â Â  outputs an MKV file with an AC3 audio track
    # ———-
    # Needed tools:
    # MKVToolnix (install Ubuntu mkvtoolnix package)
    # FAAD2 (install Ubuntu faad package)
    # Aften (install Ubuntu aften package)
    # ———-
    # Usage:
    # AAC2AC3 Input_File Output_File [Optional_Working_Directory]
    # ———-

    # initialize variables
    INPUT=$1
    OUTPUT=$2
    WORKDIR=$3

    # make things a bit more pretty
    echo

    # make sure all programs we need are installed
    if ! which mkvmerge mkvextract &> /dev/null
    then
    echo “MKVToolnix is missing.Â  Please install the mkvtoolnix package.”
    echo
    exit 1
    fi
    if ! which faad &> /dev/null
    then
    echo “FAAD2 is missing.Â  Please install the faad package.”
    echo
    exit 1
    fi
    if ! which aften &> /dev/null
    then
    echo “Aften is missing.Â  Please install the aften package.”
    echo
    exit 1
    fi

    # make sure passed variables make sense
    if [ ! "$INPUT" ]
    then
    echo “Usage: AAC2AC3 Input_File Output_File [Optional_Working_Directory]”
    echo
    echo “No input file specified.”
    echo
    exit 1
    fi
    if [ ! -f "$INPUT" ]
    then
    echo “Usage: AAC2AC3 Input_File Output_File [Optional_Working_Directory]”
    echo
    echo “Specified input file doesn’t exist.”
    echo
    exit 1
    fi
    if [ ! "$OUTPUT" ]
    then
    echo “Usage: AAC2AC3 Input_File Output_File [Optional_Working_Directory]”
    echo
    echo “No output file specified.”
    echo
    exit 1
    fi
    if [ -e "$OUTPUT" ]
    then
    echo “Usage: AAC2AC3 Input_File Output_File [Optional_Working_Directory]”
    echo
    echo “Specified output file already exists.”
    echo
    exit 1
    fi
    if [ ! "$WORKDIR" ]
    then
    WORKDIR=”`pwd`”
    fi
    if [ ! -d "$WORKDIR" ]
    then
    echo “Usage: AAC2AC3 Input_File Output_File [Optional_Working_Directory]”
    echo
    echo “Specified working directory doesn’t exist.”
    echo
    exit 1
    fi

    # check if any temp files are already present
    if [ -e "$WORKDIR/AAC2AC3Temp.mkv" ] || [ -e "$WORKDIR/AAC2AC3Temp.aac" ] || \
    [ -e "$WORKDIR/AAC2AC3Temp.ac3" ]
    then
    echo “Files AAC2AC3Temp.mkv and/or AAC2AC3Temp.aac and/or AAC2AC3Temp.ac3″
    echo “already exist in the working directory.Â  These will be overwritten.”
    echo
    echo -n 'Continue (y/n)?: '
    read CONTINUE
    echo
    if ! ([ "$CONTINUE" == "y" ] || [ "$CONTINUE" == "Y" ])
    then
    echo
    exit 1
    fi
    fi

    # check if the input file is an MP4 file
    if [[ "$INPUT" == *.mp4 ]] || [[ "$INPUT" == *.MP4 ]]
    then
    mkvmerge -o “$WORKDIR/AAC2AC3Temp.mkv” “$INPUT”
    INPUT=”$WORKDIR/AAC2AC3Temp.mkv”
    echo
    echo “**********”
    echo
    fi

    # print out details about the file in question
    mkvmerge -i “$INPUT”

    # ask which track we are converting
    echo
    echo -n 'Please specify track to be converted (look for the (A_AAC) label): '
    read TRACK
    echo

    # check if the track was properly specified
    if [ "`expr $TRACK - $TRACK 2> /dev/null`" != "0" ]
    then
    echo “Specified track has to be a numeric value.”
    echo
    exit 1
    fi
    if [ $TRACK -lt 1 ]
    then
    echo “Specified track can not be less than one.”
    echo
    exit 1
    fi

    # extract the specified track
    mkvextract tracks “$INPUT” $TRACK:”$WORKDIR/AAC2AC3Temp.aac”

    # make things pretty
    echo
    echo “**********”
    echo

    # confirm audio sample rate
    echo “Please specify audio track sample rate (press enter for default”
    echo -n “of 48000Hz): ”
    read RATE
    echo

    # setup default sample rate if needed
    if [ ! $RATE ]
    then
    RATE=48000
    fi

    # check if the rate was properly specified
    if [ "`expr $RATE - $RATE 2> /dev/null`" != "0" ]
    then
    echo “Specified sample rate has to be a numeric value.”
    echo
    exit 1
    fi
    if [ $RATE -lt 1 ]
    then
    echo “Specified sample rate can not be less than one.”
    echo
    exit 1
    fi

    # confirm number of audio channels
    echo “Please specify the number of channels in audio track (press enter”
    echo -n “for default of 6 channels): ”
    read CHANNELS

    # setup default number of channels if needed
    if [ ! $CHANNELS ]
    then
    CHANNELS=6
    fi

    # check if the rate was properly specified
    if [ "`expr $CHANNELS - $CHANNELS 2> /dev/null`" != "0" ]
    then
    echo
    echo “Specified number of channels has to be a numeric value.”
    echo
    exit 1
    fi
    if [ $CHANNELS -lt 1 ]
    then
    echo
    echo “Specified number of channels can not be less than one.”
    echo
    exit 1
    fi

    # faad outputs a raw 24 bit PCM stream (anything higher than 24 bits seems to
    # introduce anomalies) which is then piped to aften and converted to a 384 kbit/s
    # AC3 stream (640 kbit/s is max allowed and yields highest possible quality)
    faad -b 2 -f 2 -q -w “$WORKDIR/AAC2AC3Temp.aac” | aften -v 1 -b 384 \
    -raw_fmt s24_le -raw_sr $RATE -raw_ch $CHANNELS -chmap 0 – “$WORKDIR/AAC2AC3Temp.ac3″

    # make things pretty
    echo “**********”
    echo

    # check if we are appending the ac3 track or replacing any existing audio tracks
    # with the new ac3 track
    echo “The AC3 audio track can be appended (resulting MKV file will contain”
    echo “the existing audio tracks plus the new ac3 audio track) or the AC3 audio”
    echo “track can replace all existing audio tracks (resulting MKV file will”
    echo “contain only the AC3 audio track).”
    echo
    echo -n “Append or replace (press enter for default of append) (a/r): ”
    read APPENDREPLACE
    echo

    # setup default append/replace if needed
    if [ ! $APPENDREPLACE ]
    then
    APPENDREPLACE=”a”
    fi

    # do different things depending on what was specified
    if [ "$APPENDREPLACE" == "a" ] || [ "$APPENDREPLACE" == "A" ]
    then
    # merge everything back together
    mkvmerge -o “$OUTPUT” “$INPUT” “$WORKDIR/AAC2AC3Temp.ac3″
    elif [ "$APPENDREPLACE" == "r" ] || [ "$APPENDREPLACE" == "R" ]
    then
    # merge everything back together (except audio tracks from original file)
    mkvmerge -o “$OUTPUT” -A “$INPUT” “$WORKDIR/AAC2AC3Temp.ac3″
    else
    # neither append nor replace was specified
    echo “Neither append nor replace was specified.”
    echo
    exit 1
    fi

    # make things pretty
    echo

    # clean up temp files
    rm -f “$WORKDIR/AAC2AC3Temp.mkv”
    rm -f “$WORKDIR/AAC2AC3Temp.aac”
    rm -f “$WORKDIR/AAC2AC3Temp.ac3″

    # all done
    exit 0
