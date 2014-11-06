echo ""
echo "Building android:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

NDK="$(<configure/android.ndk.txt)"
echo "NDK: $NDK"

cp -f "../Spidermonkey/js/src/build-ane-android-armv7/spidermonkey-android/lib/armeabi-v7a/libjs_static.a" "../projects/android/so_arm/jni/libjs_staticARM7.a"
cp -f "../Spidermonkey/js/src/build-ane-android-x86/spidermonkey-android/lib/x86/libjs_static.a" "../projects/android/so_x86/jni/libjs_static.a"

cd $CD
cd ../projects/android/so_x86/
$NDK/ndk-build

cd $CD
cd ../projects/android/so_arm/
$NDK/ndk-build

echo "Done android!"