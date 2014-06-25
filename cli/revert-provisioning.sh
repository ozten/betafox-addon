#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

# For use by a sysadmin or a tester; reverts phone from beta testing
# back to production use

if [ $# -ne 1 ]; then
	echo "usage: revert-provisioning.sh <device_name>"
	exit 1
else
	device=$1
fi

# Be nice and wait for the user to connect the device
adb -s $device wait-for-device

profile=`adb -s $device shell ls data/b2g/mozilla | tr -d '\\r' | grep "\.default$"`

if [ -z "profile" ]; then
  echo "No user profile found on device"
  exit 1
fi

# Assumes a pristine phone that trusts marketplace
if [ -d "./backup" ]; then
  echo "\n*** Using backup to trust marketplace certs"

  adb -s $device push "./backup/user.js" /system/b2g/defaults/pref/user.js
  adb -s $device push "./backup/cert9.db" data/b2g/mozilla/$profile/cert9.db 
  adb -s $device push "./backup/key4.db" data/b2g/mozilla/$profile/key4.db 
  adb -s $device push "./backup/pkcs11.txt" data/b2g/mozilla/$profile/pkcs11.txt 

  echo "\n*** reset trusted marketplace list on device $device to $d2gHostname"
  ./change_trusted_servers.sh $device "https://marketplace.firefox.com"

else
  echo "Error: No backup directory found."
  exit 2
fi
