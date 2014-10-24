#!/bin/bash

echo ""
echo ""

# Find any simulator SDK
cd "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/"
pattern="iPhoneSimulator"
for _dir in *"${pattern}"*; do
    [ -d "${_dir}" ] && dir="${_dir}" && break
done
PLATSDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/${dir}/"
echo "PLATSDK: $PLATSDK"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
echo "CD: $CD"

# Load SDK configuration:
ADT="$(<configure.adt)"
echo "ADT: $ADT"
ACOMPC="$(<configure.acompc)"
echo "ACOMPC: $ACOMPC"

# Clean & Copy files:
rm -rf temp
mkdir temp

# Patch xml files:
SEARCH="_THIS_"
REPLACE="$(<anename.txt)"
ANENAME=$REPLACE

cat extension.xml | sed -e "s/$SEARCH/$REPLACE/g" >> ./temp/extension.xml
cp platformoptions.xml ./temp/


[[ -f "../ane/$ANENAME.ane" ]] && rm -f "../ane/$ANENAME.ane"

SWFVERSION=19

INCLUDE_CLASSES="alegorium.$ANENAME"
echo "INCLUDE_CLASSES: $INCLUDE_CLASSES"

SRCPATH="../as3/"

# Build:
echo "GENERATING SWC"
$ACOMPC -source-path $SRCPATH -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -define+=CONFIG::mock,false -output temp/$ANENAME.swc
sleep 0

cd temp
echo "GENERATING LIBRARY from SWC"

unzip $ANENAME.swc
sleep 0
[[ -f "catalog.xml" ]] && rm -f "catalog.xml"

echo "GENERATING ANE"



sleep 0

mv $ANENAME.ane ../../ane/

# Clean:
[[ -f "library.swf" ]] && rm -f "library.swf"
[[ -f "$ANENAME.swc" ]] && rm -f "$ANENAME.swc"
cd ..
rm -rf temp

echo "DONE!"