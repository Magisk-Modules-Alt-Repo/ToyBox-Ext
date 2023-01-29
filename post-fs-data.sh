#!/system/bin/sh

#Magisk Module ToyBox-Ext v1.0.4
#Copyright (c) zgfg @ xda, 2022-

# Module's own path (local path)
MODDIR=${0%/*}

# System XBIN path
XBINDIR=/system/xbin

# Local XBIN and (or) BIN paths for mounting
TBXBINDIR=$MODDIR$XBINDIR
TBBINDIR=$MODDIR/system/bin

# Use local XBIN path if System XBIN path exists, otherwise use local BIN path
if [ -d $XBINDIR ]
then
  TBDIR=$TBXBINDIR
else
  TBDIR=$TBBINDIR
fi

# Clean-up local XBIN and BIN paths
rm -rf $TBXBINDIR
rm -rf $TBBINDIR
mkdir -p $TBDIR
cd $TBDIR

# Install toybox-stock binary if found in the path
TB=toybox
TBBIN=$(which $TB)
if [ ! -z "$TBBIN" ]
then
  Applets=$($TBBIN)
fi

# Create symlinks for toybox-stock applets
for Applet in $Applets
do
  # Skip if applet already found in the path
  Check=$(which $Applet)
  if [ -z "$Check" ]
  then
    ln -s $TBBIN $Applet
  fi
done

# List toybox-ext applets
TB=toybox-ext
TBBIN=$MODDIR/$TB
Applets=$TB$'\n'$($TBBIN)

# Create symlinks for toybox-ext applets
for Applet in $Applets
do
  # Skip if applet already found in the path
  Check=$(which $Applet)
  if [ -z "$Check" ]
  then
    ln -s $TBBIN $Applet
  fi
done
