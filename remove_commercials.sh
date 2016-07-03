#!/bin/sh

##### Commercial Remover Script for MythTV, updated 5/14/12
###
##       Version Changes to mythutil and mythcommflag tools under MythTV 0.25  
##        necessitate different commands within the script. (Under MythTV < 0.25 you could 
##        just point mythcommflag at the recordings in the file system and get the job done, now
##        under MythTV 0.25 you have to use mythutil to generate the cutlist and mythcommflag to
##        flag commercials, AND point both at recordings based on %CHANID% and %STARTTIME%.  Under 
##        MythTV 0.25 mythtranscode can also be pointed at %CHANID% and %STARTTIME% but since it
##        currently supports the older infile /outfile method as well (and I prefer how this
##        script creates old/new files, it is the method used.
##
##      Since this script requires the User Job to pass additional arguments under MythTV 0.25,
##       use following User Job syntax for userjobs under all versions:
##
##        'commercialremover.sh %DIR% %FILE% %CHANID% %STARTTIME%'
##
##      Credits: Zwhite, Ricks03, Waxrat @ www.mythtv.org/wiki
###
#####
VIDEODIR=$1 #MythTV-024 %DIR%
FILENAME=$2 #MythTV-024 %FILE%
CHAN=$3 #REQUIRED FOR MythTV-025 %CHANID%
START=$4 #REQUIRED FOR MythTV-025 %STARTTIME%

# Sanity checking, to make sure everything is in order. Modified to check $CHAN and $START for MythTV 0.25 Support
if [ -z "$VIDEODIR" -o -z "$FILENAME" -o -z "$CHAN" -o -z "$START"]; then
        echo "Usage: $0 <VideoDirectory> <FileName>"
        exit 5
fi
if [ ! -f "$VIDEODIR/$FILENAME" ]; then
        echo "File does not exist: $VIDEODIR/$FILENAME"
        exit 6
fi
# The meat of the script. Flag commercials, copy the flagged commercials to
# the cutlist, and transcode the video to remove the commercials from the
# file.


echo "Flagging Commercials..."
##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version <= 0.24
#mythcommflag -f $VIDEODIR/$FILENAME

##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version >= 0.25
mythcommflag --chanid $CHAN --starttime $START
ERROR=$?
if [ $ERROR -gt 126 ]; then
        echo "Commercial flagging failed for ${FILENAME} with error $ERROR"
        exit $ERROR
fi


echo "Generating cutlist..."
##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version <= 0.24
#mythcommflag --gencutlist -f $VIDEODIR/$FILENAME

##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version >= 0.25
mythutil --gencutlist --chanid $CHAN --starttime $START
ERROR=$?
if [ $ERROR -ne 0 ]; then
        echo "Copying cutlist failed for ${FILENAME} with error $ERROR"
        exit $ERROR
fi


echo "Transcoding..."
mythtranscode --honorcutlist --showprogress -i $VIDEODIR/$FILENAME -o $VIDEODIR/$FILENAME.tmp
ERROR=$?
if [ $ERROR -ne 0 ]; then
        echo "Transcoding failed for ${FILENAME} with error $ERROR"
        exit $ERROR
fi
mv $VIDEODIR/$FILENAME $VIDEODIR/$FILENAME.old
mv $VIDEODIR/$FILENAME.tmp $VIDEODIR/$FILENAME


echo "Rebuilding..."
##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version <= 0.24
#mythcommflag -f $VIDEODIR/${FILENAME} --rebuild

##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version >= 0.25
mythcommflag --chanid $CHAN --starttime $START --rebuild
ERROR=$?
if [ $ERROR -ne 0 ]; then
        echo "Rebuilding seek list failed for ${FILENAME} with error $ERROR"
        exit $ERROR
fi


echo "Clearing cutlist..."
##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version <= 0.24
#mythcommflag --clearcutlist -f $VIDEODIR/$FILENAME

##### - UNCOMMENT FOLLOWING LINE IF RUNNING MythTV Version >= 0.25
mythutil --clearcutlist --chanid $CHAN --starttime $START
ERROR=$?
if [ $ERROR -eq 0 ]; then
        # Fix the database entry for the file 
##### - Note: MAY need to add mysql mythconverg DB credentials '--user=<blah> --password=<blah>' 
##       to the 'mysql mythconverg' command below.)
        # Fix the database entry for the file 
        cat << EOF | mysql mythconverg
UPDATE 
        recorded
SET
        cutlist = 0,
        filesize = $(ls -l $VIDEODIR/$FILENAME | awk '{print $5}') 
WHERE
        basename = '$FILENAME';
DELETE FROM 
       `recordedmarkup`
WHERE 
       CONCAT( chanid, starttime ) IN (
               SELECT 
                       CONCAT( chanid, starttime )
               FROM 
                       recorded
               WHERE 
                       basename = '$FILENAME'
      );
EOF
        exit 0
else
        echo "Clearing cutlist failed for ${FILENAME} with error $ERROR"
        rm -f $VIDEODIR/$FILENAME.tmp
        exit $ERROR
fi

