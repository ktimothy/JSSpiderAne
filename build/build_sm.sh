echo ""
echo "Building SpiderMonkey:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

../Spidermonkey/js/src/build-ane-osx-x86/build.sh
../Spidermonkey/js/src/build-ane-ios-armv7/build.sh
../Spidermonkey/js/src/build-ane-ios-x86/build.sh
../Spidermonkey/js/src/build-ane-android-armv7/build.sh
../Spidermonkey/js/src/build-ane-android-x86/build.sh

echo "Done SpiderMonkey!"