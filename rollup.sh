#!/bin/bash
set -eu

pushd .
pushd ~/openwrt
cp -f ~/mwl8k-working/008-fix_netdev_unregister.patch package/kernel/mac80211/patches/008-fix_netdev_unregister.patch
if [ $? != 0 ]
then
	exit $?
fi
prep="$(make package/kernel/mac80211/{clean,prepare} V=s QUILT=1)"
if [ $? != 0 ] 
then
	exit $?
fi
pushd build_dir/target*/linux-mvebu/compat-wireless*/
quilt_push="$(quilt push -a)"
if [ $? != 0 ] 
then
	exit $?
fi
cp -f ~/mwl8k-working/mwl8k.c ./drivers/net/wireless/mwl8k.c
lines="$(quilt diff | wc -l)"
if [ $? != 0 ] 
then
	exit $?
else
	if [ -z "$lines" ] || [ $((lines)) -eq 0 ]
	then
		echo "no output from quilt diff"
		exit 1
	fi
fi
refresh="$(quilt refresh)"
if [ $? != 0 ]
then
	exit $?
fi
popd
build_patched="$(make package/kernel/mac80211/{update,clean,compile} V=s)"
if [ $? != 0 ]
then
	exit $?
fi
cp -f ~/openwrt/package/kernel/mac80211/patches/930-mwl8k-initial-support-for-88W8864.patch ~/mwl8k-working/
if [ $? != 0 ]
then
	exit $?
fi
