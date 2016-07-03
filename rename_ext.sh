#!/bin/bash
#  Simple Script to change file extensions
#+ relies on rename command, not very portable
#+ but I dont care
case $# in
0|1)
	echo "rename_ext.sh - Change specified file extension recursively";
	echo "Usage: rename_ext.sh <CURRENT> <NEW>";
	exit $E_BADARGS  # If 0 or 1 arg, then bail out.
	;;
esac

#  we remove leading '.' if it exists in order to comply with
#+ any form the user types extensions.
#  We then add the '.' if the new extension isn't NULL
OLD_EXT=${1#\.};

if [ "$2" == "" ]; then
	NEW_EXT="";
else
	NEW_EXT=${2#\.};
	NEW_EXT=".$NEW_EXT";
fi
find -name "*.$OLD_EXT" -type f -exec rename "s/\.$OLD_EXT$/$NEW_EXT/" {} +

