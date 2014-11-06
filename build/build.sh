# BUILDS EVERYTHING
echo ""
echo ""
echo ""
echo "Building everything:"

# Go into current location:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CD=$DIR
cd $CD
echo "CD: $CD"

./build_sm.sh
./build_ane.sh

echo "Done everything!"