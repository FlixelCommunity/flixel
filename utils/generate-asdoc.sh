#!/bin/bash

source utils/config

FLEX_SDK_LOCATION=`utils/flex-sdk`

if [ $? -eq 0 ];then

	asdoc_args=(-source-path="$SOURCE_CODE_LOCATION")
	asdoc_args+=(-doc-sources="$SOURCE_CODE_LOCATION")
	asdoc_args+=(-output="$ASDOC_OUTPUT_LOCATION")
	
	# Only include the library folder if it exists
	[ -d "$LIBRARY_LOCATION" ] && asdoc_args+=(-library-path+="$LIBRARY_LOCATION")
	
	"$FLEX_SDK_LOCATION"/bin/asdoc "${asdoc_args[@]}";

else

	# Echo out the error message from running the script
	echo "$FLEX_SDK_LOCATION";
	exit 1;

fi
