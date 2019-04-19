#!/bin/bash
# Kali NetHunter kernel for Huawei Nexus 6P build script by jcadduono

################### BEFORE STARTING ################
#
# download a working toolchain and extract it somewhere and configure this
# file to point to the toolchain's root directory.
#
# once you've set up the config section how you like it, you can simply run
# ./build.sh [VARIANT]
#
###################### CONFIG ######################

# root directory of angler git repo (default is this script's location)
RDIR=$(pwd)

[ "$VER" ] ||
# version number
VER=$(cat "$RDIR/VERSION")

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=/root/Downloads/clang-android-toolchain/clang-r353983b

CPU_THREADS=$(grep -c "processor" /proc/cpuinfo)
# amount of cpu threads to use in kernel make process
THREADS=$((CPU_THREADS + 1))

############## SCARY NO-TOUCHY STUFF ###############

ABORT() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

CONTINUE=false
export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/

[ -x "${CROSS_COMPILE}clang" ] ||
ABORT "Unable to find gcc cross-compiler at location: ${CROSS_COMPILE}clang"

while [ $# != 0 ]; do
	if [ "$1" = "--continue" ] || [ "$1" == "-c" ]; then
		CONTINUE=true
	elif [ ! "$TARGET" ]; then
		TARGET=$1
	elif [ ! "$DEVICE" ]; then
		DEVICE=$1
	else
		echo "Too many arguments!"
		echo "Usage: ./build.sh [--continue] [device] [target defconfig]"
		ABORT
	fi
	shift
done

[ "$DEVICE" ] || DEVICE=angler
[ "$TARGET" ] || TARGET=nethunter
DEFCONFIG=nethunter_defconfig

[ -f "$RDIR/arch/$ARCH/configs/${DEFCONFIG}" ] ||
ABORT "Config $DEFCONFIG not found in $ARCH configs!"

export LOCALVERSION=$TARGET-$DEVICE-$VER

CLEAN_BUILD() {
	echo "Cleaning build..."
	rm -rf build
}

SETUP_BUILD() {
	echo "Creating kernel config for $LOCALVERSION..."
	mkdir -p build
	make -C "$RDIR" O=build "$DEFCONFIG" \
		|| ABORT "Failed to set up build"
}

BUILD_KERNEL() {
	echo "Starting build for $LOCALVERSION..."
	while ! make -C "$RDIR" O=build -j"$THREADS"; do
		read -rp "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) return 1 ;;
		esac
	done
}

INSTALL_MODULES() {
	grep -q 'CONFIG_MODULES=y' build/.config || return 0
	echo "Installing kernel modules to build/lib/modules..."
	while ! make -C "$RDIR" O=build \
			INSTALL_MOD_PATH="." \
			INSTALL_MOD_STRIP=1 \
			modules_install
	do
		read -rp "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) return 1 ;;
		esac
	done
	rm build/lib/modules/*/build build/lib/modules/*/source
}

cd "$RDIR" || ABORT "Failed to enter $RDIR!"

if ! $CONTINUE; then
	CLEAN_BUILD
	SETUP_BUILD ||
	ABORT "Failed to set up build!"
fi

BUILD_KERNEL &&
INSTALL_MODULES &&
echo "Finished building $LOCALVERSION!"