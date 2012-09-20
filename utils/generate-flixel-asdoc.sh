#! /bin/sh

# NOTE: These variables are relative to where you are calling the script from,
#	NOT the location of the script!
FLEX_SDK_LOCATION="/Applications/Adobe Flash Builder 4 Plug-in/sdks/4.0.0"
CODE_LOCATION="."
TARGET_LOCATION="docs"

"$FLEX_SDK_LOCATION"/bin/asdoc -source-path "$CODE_LOCATION" -doc-sources "$CODE_LOCATION" -output "$TARGET_LOCATION"
