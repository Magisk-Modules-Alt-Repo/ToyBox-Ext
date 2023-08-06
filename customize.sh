#!/system/bin/sh

# Magisk Module: ToyBox-Ext v1.0.9
# Copyright (c) zgfg @ xda, 2022-
# GitHub source: https://github.com/zgfg/ToyBox-Ext

if [ -z $BOOTMODE ] ||  [ "$BOOTMODE" != "true" ] 
then
	abort "ERROR: Install from Magisk app, not from TWRP!"
fi

# Log file for debugging
LogFile="$MODPATH/customize.log"

# Uncomment for logging
#exec 3>&2 2>$LogFile 1>&2
#set -x
#date +%c
#magisk -c
#magisk --path

# Module's own path (local path)
cd $MODPATH
pwd

# toybox ARMv7 and higher binaries
TBTYPEList="
toybox-aarch64
toybox-armv7m
toybox-armv7l
"

# toybox binary to be installed
TBEXT=toybox-ext

# Find the applicable binary
TBTYPE=""
for TB in $TBTYPEList
do
  if [ -z $TBTYPE ]
  then
    # Test if binary executes 
    echo "Testing archived $TB"
    chmod 755 $TB
    Applets=$(./$TB)

    if [ ! -z "$Applets" ]
    then
      # Applicable binary found
      TBTYPE=$TB
      mv $TBTYPE $TBEXT
      Version=$(./$TBEXT --version)
      echo "Archived $TBTYPE $Version installed"
      continue
    fi
  fi

  # Delete binary (already found or doesn't execute)
  rm -f $TB
done

if [ -z $TBTYPE ]
then
  # Applicable binary not found
  echo
  echo "ERROR: ToyBox not installed!"
  echo
  echo "$(cat /proc/cpuinfo)"
  echo
  exit -1
fi

# Current time
DLTIME=$(date +"%s")

# Save the toybox binary type and installation time
TBSCRIPT='./tbtype.sh'
echo "TBTYPE=$TBTYPE" > $TBSCRIPT
echo "LASTDLTIME=$DLTIME" >> $TBSCRIPT

# Download latest binary
echo "Downloading latest $TBTYPE"
wget -c -T 10 "http://landley.net/toybox/bin/$TBTYPE"

# Test the download 
if [ ! -f $TBTYPE ]
then
  # Not downloaded 
  echo "$TBTYPE not downloaded"
else
  echo "Testing downloaded $TBTYPE"
  # Compare checksums for the old and new binary
  MD5Old=$(md5sum $TBEXT | head -c 32)
  MD5New=$(md5sum "$TBTYPE" | head -c 32)
  if [ "$MD5New" = "$MD5Old" ]
  then
    # Delete, same as old binary
    echo "Downloaded $TBTYPE same version as installed"
    rm -f $TBTYPE
  else
    # Test downloaded binary
    chmod 755 $TBTYPE
    Applets=$(./$TBTYPE)
    if [ -z "$Applets" ]
    then
      # Delete, not working
      echo "Downloaded $TBTYPE not working"
      rm -f $TBTYPE
    else
    # Install
    mv $TBTYPE $TBEXT
    Version=$(./$TBEXT --version)
    echo "Downloaded $TBTYPE $Version installed"
    fi
  fi
fi
