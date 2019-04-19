#!/bin/bash
# simple script for executing menuconfig

# root directory of angler git repo (default is this script's location)
RDIR=$(pwd)

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=/root/Downloads/clang-android-toolchain/clang-r353983b

############## SCARY NO-TOUCHY STUFF ###############

ABORT() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/

[ -x "${CROSS_COMPILE}clang-9" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}clang-9"

while [ $# != 0 ]; do
	if [ ! "$DEVICE" ]; then
		DEVICE=$1
	elif [ ! "$TARGET" ]; then
		TARGET=$1
	else
		echo "Too many arguments!"
		echo "Usage: ./menuconfig.sh [device] [target defconfig]"
		ABORT
	fi
	shift
done

[ "$DEVICE" ] || DEVICE=enchilada
[ "$TARGET" ] || TARGET=nethunter
DEFCONFIG=nethunter_defconfig
DEFCONFIG_FILE=$RDIR/arch/$ARCH/configs/$DEFCONFIG

[ -f "$DEFCONFIG_FILE" ] ||
ABORT "Device config $DEFCONFIG not found in $ARCH configs!"

cd "$RDIR" || ABORT "Failed to enter $RDIR!"

echo "Cleaning build..."
rm -rf build
mkdir build
make -s -i -C "$RDIR" O=build "$DEFCONFIG" menuconfig
echo "Showing differences between old config and new config"
echo "-----------------------------------------------------"
if command -v colordiff >/dev/null 2>&1; then
	diff -Bwu --label "old config" "$DEFCONFIG_FILE" --label "new config" build/.config | colordiff
else
	diff -Bwu --label "old config" "$DEFCONFIG_FILE" --label "new config" build/.config
	echo "-----------------------------------------------------"
	echo "Consider installing the colordiff package to make diffs easier to read"
fi
echo "-----------------------------------------------------"
echo -n "Are you satisfied with these changes? y/N: "
read -r option
case $option in
y|Y)
	cp build/.config "$DEFCONFIG_FILE"
	echo "Copied new config to $DEFCONFIG_FILE"
	;;
*)
	echo "That's unfortunate"
	;;
esac
echo "Cleaning build..."
rm -rf build
echo "Done."