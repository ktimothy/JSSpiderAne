#!/bin/bash

echo ""
echo "Making ANE..."

# Find current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR

# Find any simulator SDK
cd "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/"
pattern="iPhoneSimulator"
for _dir in *"${pattern}"*; do
    [ -d "${_dir}" ] && dir="${_dir}" && break
done
PLATSDK="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/${dir}/"
echo "PLATSDK: $PLATSDK"

# Go into current location:
cd $CD
echo "CD: $CD"

# Load SDK configuration:
ADT="$(<./configure/air.sdk.txt)/bin/adt"
echo "ADT: $ADT"
ACOMPC="$(<./configure/air.sdk.txt)/bin/acompc"
echo "ACOMPC: $ACOMPC"

# Clean & Copy files:
rm -rf temp
mkdir temp
mkdir temp/ios
mkdir temp/mac

# Patch xml files:
SEARCH="_THIS_"
REPLACE="$(<anename.txt)"
ANENAME=$REPLACE

cat extension.xml | sed -e "s/$SEARCH/$REPLACE/g" >> ./temp/extension.xml
cp platformoptions.xml ./temp/

# Copy binaries:
mkdir -p temp/ios/x86
mkdir -p temp/ios/armv7

mv -f ../projects/xcode/JSSpiderANE/Build/Products/Release-iphonesimulator/libJSSpideriOS.a ./temp/ios/x86/JSSpiderANE386.a
mv -f ../projects/xcode/JSSpiderANE/Build/Products/Release-iphoneos/libJSSpideriOS.a ./temp/ios/armv7/JSSpiderANE.a

cp -rf ../projects/xcode/JSSpiderANE/Build/Products/Release/JSSpiderANE.framework ./temp/mac/JSSpiderANE.framework
rm -rf ./temp/mac/JSSpiderANE.framework/Versions/
# android:
mkdir -p temp/android/libs/armeabi-v7a
mkdir -p temp/android/libs/x86

# win32:
mkdir -p temp/win32
cp -f ../projects/win32/AIR_DLL/Win32Project1/Release/Win32Project.dll ./temp/win32/JSSpiderANE.dll
cp -f ../projects/win32/AIR_DLL/Win32Project1/Win32Project1/mozjs-28.dll ./temp/win32/mozjs-28.dll

cp "../projects/android/so_arm/libs/armeabi-v7a/libjs_staticARM7.so" temp/android/libs/armeabi-v7a/libalegorium.ane.$REPLACE.so
cp "../projects/android/so_x86/libs/x86/libjs_static.so" temp/android/libs/x86/libalegorium.ane.$REPLACE.so

[[ -f "../ane/$ANENAME.ane" ]] && rm -f "../ane/$ANENAME.ane"

SWFVERSION=26

INCLUDE_CLASSES="alegorium.$ANENAME"
echo "INCLUDE_CLASSES: $INCLUDE_CLASSES"

SRCPATH="../as3/"

# Build:
echo "GENERATING SWC"
if test "../as3/alegorium/$ANENAME.as" -nt "../as3/alegorium/$ANENAME.swc"; then
# file1 -nt file2;
# file1 is newer than file2
$ACOMPC -source-path $SRCPATH -include-classes $INCLUDE_CLASSES -swf-version=$SWFVERSION -define+=CONFIG::mock,false -output ../as3/alegorium/$ANENAME.swc
fi

cp -rf "../as3/alegorium/$ANENAME.swc" "temp/$ANENAME.swc"
sleep 0

cd temp
echo "GENERATING LIBRARY from SWC"

unzip $ANENAME.swc
sleep 0
[[ -f "catalog.xml" ]] && rm -f "catalog.xml"

cp -rf "library.swf" "mac/library.swf"
cp -rf "library.swf" "ios/x86/library.swf"
cp -rf "library.swf" "ios/armv7/library.swf"
cp -rf "library.swf" "android/libs/armeabi-v7a/library.swf"
cp -rf "library.swf" "android/libs/x86/library.swf"
cp -rf "library.swf" "win32/library.swf"

echo "GENERATING ANE"

# Only Mac
#$ADT -package -target ane $ANENAME.ane extension.xml -swc $ANENAME.swc -platform default library.swf -platform MacOS-x86 -C ./mac .

# Mac & iOS Sim
#$ADT -package -target ane $ANENAME.ane extension.xml -swc $ANENAME.swc -platform default library.swf -platform MacOS-x86 -C ./mac . -platform iPhone-x86 -C ./ios/ . -platformoptions platformoptions.xml

# Mac & iOS & iOS Sim
#$ADT -package -target ane $ANENAME.ane extension.xml -swc $ANENAME.swc -platform default library.swf -platform MacOS-x86 -C ./mac . -platform iPhone-x86 -C ./ios/ . -platform iPhone-ARM -C ./ios/ . -platformoptions platformoptions.xml
#Mac & iOS & iOS Sim & Android
#$ADT -package -target ane $ANENAME.ane extension.xml -swc $ANENAME.swc -platform default library.swf -platform MacOS-x86 -C ./mac . -platform Android-ARM -C ./android/libs/armeabi-v7a . -platform Android-x86 -C ./android/libs/x86 . -platform iPhone-x86 -C ./ios/x86/ . -platform iPhone-ARM -C ./ios/armv7/ . -platformoptions platformoptions.xml

#Mac & iOS & iOS Sim & Android & Win32
$ADT -package -target ane $ANENAME.ane extension.xml -swc $ANENAME.swc -platform default library.swf -platform Windows-x86 -C ./win32 . -platform MacOS-x86 -C ./mac . -platform Android-ARM -C ./android/libs/armeabi-v7a . -platform Android-x86 -C ./android/libs/x86 . -platform iPhone-x86 -C ./ios/x86/ . -platform iPhone-ARM -C ./ios/armv7/ . -platformoptions platformoptions.xml


sleep 0

mv $ANENAME.ane ../../ane/

# Clean:
[[ -f "library.swf" ]] && rm -f "library.swf"
[[ -f "$ANENAME.swc" ]] && rm -f "$ANENAME.swc"
cd ..

mv -f ./temp/ios/x86/JSSpiderANE386.a ../projects/xcode/JSSpiderANE/Build/Products/Release-iphonesimulator/libJSSpideriOS.a
mv -f ./temp/ios/armv7/JSSpiderANE.a ../projects/xcode/JSSpiderANE/Build/Products/Release-iphoneos/libJSSpideriOS.a
rm -rf temp

echo "DONE!"