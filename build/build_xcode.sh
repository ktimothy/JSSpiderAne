echo ""
echo "Building xcode:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

cd ../projects/xcode/JSSpiderANE/

rm -rf "./Build/Products/"

xcodebuild -project JSSpiderANE.xcodeproj -target JSSpiderANE

xcodebuild -project JSSpiderANE.xcodeproj -target JSSpideriOS -arch armv7 -sdk iphoneos

xcodebuild -project JSSpiderANE.xcodeproj -target JSSpideriOS -arch i386 -sdk iphonesimulator

mkdir -p "./Build/Products/"

mv "./Build/Release" "./Build/Products/Release"
mv "./Build/Release-iphoneos" "./Build/Products/"
mv "./Build/Release-iphonesimulator" "./Build/Products/"

echo "Done xcode!"