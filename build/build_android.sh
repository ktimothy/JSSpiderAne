echo ""
echo "Building android:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

NDKBUILD="$(<configure/android.ndk.txt)"
echo "NDKBUILD: $NDKBUILD"

echo "Done android!"