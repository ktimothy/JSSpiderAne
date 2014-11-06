echo ""
echo "Building ANE:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
#echo "CD: $CD"

./build_android.sh
./build_xcode.sh
./build_win.sh
./make_this_ane.sh

echo "Done ANE!"