echo ""
echo "Building SpiderMonkey:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

NDK="$(<./configure/android.ndk.txt)"

../Spidermonkey/js/src/build-ane-osx-x86/build.sh
../Spidermonkey/js/src/build-ane-ios-armv7/build.sh
../Spidermonkey/js/src/build-ane-ios-x86/build.sh
../Spidermonkey/js/src/build-ane-android-armv7/build.sh $NDK
../Spidermonkey/js/src/build-ane-android-x86/build.sh $NDK

echo "Done SpiderMonkey!"