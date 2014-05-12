#!/bin/bash

source utils/config

FLEX_SDK_LOCATION=`utils/flex-sdk`

if [ $? -eq 0 ];then

	"$FLEX_SDK_LOCATION"/bin/asdoc -source-path "$SOURCE_CODE_LOCATION" -doc-sources "$SOURCE_CODE_LOCATION" -output "$ASDOC_OUTPUT_LOCATION"

else

	# Echo out the error message from running the script
	echo "$FLEX_SDK_LOCATION";
	exit 1;

fi
