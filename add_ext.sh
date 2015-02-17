#!/bin/bash
#  Simple script to add fie extensions
case $# in
0)
	echo "add_ext.sh - Add specified file extension recursively";
	echo "Usage: add_ext.sh <EXTENSION>";
	exit $E_BADARGS  # If 0 arg, then bail out.
	;;
esac

#  we remove leading '.' if it exists in order to comply with
EXT=${1#\.};
find ! -name "*.$EXT" -type f -exec rename "s/$/\.$EXT/" {} +

