#!/system/bin/sh

# Magisk Module: ToyBox-Ext v1.0.5
# Copyright (c) zgfg @ xda, 2022-
# GitHub source: https://github.com/zgfg/ToyBox-Ext

if [ -z $BOOTMODE ] ||  [ "$BOOTMODE" != "true" ] 
then
	abort "ERROR: Install from Magisk app, not from TWRP!"
fi

# Module's own path (local path)
cd $MODPATH

# toybox ARMv7 and higher binaries
TBBINList="
toybox-aarch64
toybox-armv7m
toybox-armv7l
"

# toybox binary to be installed
TBEXT=toybox-ext

# Find the applicable binary
TBBIN=""
for TB in $TBBINList
do
  if [ -z $TBBIN ]
  then
    # Test if binary executes 
    echo "Testing archived $TB"
    chmod 755 $TB
    Applets=$(./$TB)

    if [ ! -z "$Applets" ]
    then
      # Applicable binary found
      TBBIN=$TB
      mv $TBBIN $TBEXT
      echo "Archived $TBBIN installed"
      continue
    fi
  fi

  # Delete binary (already found or doesn't execute)
  rm -f $TB
done

if [ -z $TBBIN ]
then
  # Applicable binary not found
  echo
  echo "ERROR: ToyBox not installed!"
  echo
  getprop | grep 'cpu\.abi'
  echo
  exit -1
fi

# Download latest binary
echo "Downloading latest $TBBIN"
wget -c -T 10 "http://landley.net/toybox/bin/$TBBIN"

# Test the download 
if [ ! -e $TBBIN ]
then
  # Not downloaded 
  echo "$TBBIN not downloaded"
else
  echo "Testing downloaded $TBBIN"
  chmod 755 $TBBIN
  Applets=$(./$TBBIN)
  if [ "$Applets" ]
  then
    # Install 
    mv $TBBIN $TBEXT
    echo "Downloaded $TBBIN installed instead"
  else
    # Delete, not working
    echo "Use archived $TBBIN instead"
    echo "$TBBIN NOK"
    rm -f $TBBIN
  fi
fi
