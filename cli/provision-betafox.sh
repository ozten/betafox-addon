#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

# For use by a sysadmin or a tester; configures a phone to do beta testing
# of privileged open web apps

# see https://github.com/wfwalker/marketplace-certs
# see https://github.com/digitarald/d2g
# see https://wiki.mozilla.org/Marketplace/Reviewers/Apps/InstallingReviewerCerts

if [ $# -ne 2 ]; then
	echo "usage: provision-betafox.sh <device_name> <endpoint>"
        echo "./provision-betafox.sh full_unagi http://10.0.1.13:8000"
	exit 1
else
	device=$1
	d2gHostname=$2
fi

# Assumes a pristine phone that trusts marketplace
if [ ! -d "./backup" ]; then
  echo "\n*** backing up marketplace certs"
  mkdir ./backup

  # Be nice and wait for the user to connect the device
  adb -s "$device" wait-for-device

  profile=`adb -s $device shell ls data/b2g/mozilla | tr -d '\\r' | grep "\.default$"`

  if [ -z "profile" ]; then
    echo "No user profile found on device"
    exit 1
  fi

  # get prefs from phone
  adb pull /system/b2g/defaults/pref/user.js "./backup/user.js"

  adb -s "$device" pull data/b2g/mozilla/$profile/cert9.db "./backup/cert9.db" 
  adb -s "$device" pull data/b2g/mozilla/$profile/key4.db "./backup/key4.db" 
  adb -s "$device" pull data/b2g/mozilla/$profile/pkcs11.txt "./backup/pkcs11.txt" 
fi


echo "\n*** provision-betafox"

echo "\n*** wiping temporary cert DB"
rm -Rf certdb.tmp

echo "\n*** create new temporary cert DB"
mkdir certdb.tmp


for publicFile in cert9.db key4.db  pkcs11.txt; do
  echo "\n*** fetching ${d2gHostname}/${publicFile}"
  wget "${d2gHostname}/${publicFile}" -O certdb.tmp/${publicFile}
  wgetResponse=$?
  if [ $wgetResponse -ne 0 ]; then
    echo "could not download DER file from $derFileURL, check your hostname and server and try again"
    exit 1
  fi
done

if [ "$device" == 'unknown' ]; then
	echo "Firefox OS device not found."
	echo "Please connect your device via ADB, turn it on, unlock it, enable remote debugging, and try again"

	exit 1
else
	echo "found device $device"
fi

echo "\n*** push temporary cert DB to device $device"       
./push_certdb.sh "$device" certdb.tmp

echo "\n*** reset trusted marketplace list on device $device to $d2gHostname"
./change_trusted_servers.sh "$device" "$d2gHostname"

