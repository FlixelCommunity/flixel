#!/bin/bash

source utils/config

FLEX_SDK_LOCATION=`utils/flex-sdk`

if [ $? -eq 0 ];then
	
	if [ "$PROJECT_VERSION" = auto ]; then
		PROJECT_VERSION=`git describe`
		if [ $? -ne 0 ]; then
			echo "WARNING: Cannot automatically generate a version number for $PROJECT_NAME."
			echo "    Tag the repository, or manually edit the 'PROJECT_VERSION' variable inside the 'config' file."
			PROJECT_VERSION=''
		fi
	fi
	
	if [ "$PROJECT_VERSION" ]; then
		SWC_NAME="$PROJECT_NAME-$PROJECT_VERSION.swc"
	else
		SWC_NAME="$PROJECT_NAME.swc"
	fi
	
	compc_args=(-source-path="$SOURCE_CODE_LOCATION")
	compc_args+=(-include-sources="$SOURCE_CODE_LOCATION")
	compc_args+=(-output="$SWC_OUTPUT_LOCATION/$SWC_NAME")
	
	# Only include the library folder if it exists
	[ -d "$LIBRARY_LOCATION" ] && compc_args+=(-library-path+="$LIBRARY_LOCATION")
	
	"$FLEX_SDK_LOCATION"/bin/compc "${compc_args[@]}";

else

	# Echo out the error message from running the script
	echo "$FLEX_SDK_LOCATION";
	exit 1;

fi
