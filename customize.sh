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
      echo "Archived $TBTYPE installed"
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
  getprop | grep 'cpu\.abi'
  echo
  exit -1
fi

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
  chmod 755 $TBTYPE
  Applets=$(./$TBTYPE)
  if [ ! -z "$Applets" ]
  then
    # Install 
    mv $TBTYPE $TBEXT
    echo "Downloaded $TBTYPE installed instead"
  else
    # Delete, not working
    echo "Use archived $TBTYPE instead"
    rm -f $TBTYPE
  fi
fi

# Current time
DLTIME=$(date +"%s")

# Save the toybox binary type and installation time
echo "TBTYPE=$TBTYPE" > tbtype.sh
echo "LASTDLTIME=$DLTIME" >> tbtype.sh
