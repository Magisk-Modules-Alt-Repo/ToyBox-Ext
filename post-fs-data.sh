#!/system/bin/sh

# Magisk Module: ToyBox-Ext v1.0.9
# Copyright (c) zgfg @ xda, 2022-
# GitHub source: https://github.com/zgfg/ToyBox-Ext

# Module's own path (local path)
MODDIR=${0%/*}

# Log file for debugging
LogFile="$MODDIR/post-fs-data.log"
exec 2>$LogFile 1>&2
set -x

# Log Magisk version and magisk --path
magisk -c
magisk --path

# Source the original toybox binary type
cd $MODDIR
pwd
TBSCRIPT='./tbtype.sh'
if [ -f $TBSCRIPT ]
then
  . $TBSCRIPT
fi

# ToyBox-Ext
TB=toybox
TBEXT=toybox-ext
if [ ! -z $TBTYPE ] && [ -f $TBTYPE ]
then
  # Replace toybox-ext with the latest downloaded binary
  mv $TBTYPE $TBEXT
fi
chmod 755 $TBEXT

# Clean-up old stuff
rm -rf "$MODDIR/system"

# Choose XBIN or BIN path
SDIR=/system/xbin
if [ ! -d $SDIR ]
then
  SDIR=/system/bin
fi
TBDIR=$MODDIR$SDIR
mkdir -p $TBDIR
cd $TBDIR
pwd

# ToyBox-Ext applets
TBEXTBIN=$MODDIR/$TBEXT
Applets=$TB$'\n'$TBEXT$'\n'$($TBEXTBIN)

# Create symlinks for toybox-ext applets
for Applet in $Applets
do
  if [ ! -x $SDIR/$Applet ]
  then
    # Create symlink
    ln -s $TBEXTBIN $Applet
  fi
done

# Stock ToyBox applets
TBSTOCK=$(which $TB)
Applets=""
if [ ! -z "$TBSTOCK" ]
then
  TBPATH=$(echo "$TBSTOCK" | sed "s,/$TB$,,")
  Applets=$TB$'\n'$($TBSTOCK)
fi

# Create symlinks for toybox-stock applets
for Applet in $Applets
do
 if [ ! -h "$Applet" ] && [ ! -x "$TBPATH/$Applet" ] && [ ! -x "$SDIR/$Applet" ]
  then
    # Create symlink
    ln -s $TBSTOCK $Applet
  fi
done
chmod 755 *
chcon u:object_r:system_file:s0 *

# Log results for ToyBox-Ext
ls -lZ $TBEXT
$TBEXTBIN --version
ls -l | grep $TBEXT | grep ^lr.x | rev | cut -d ' ' -f 3 | rev
ls -l | grep $TBEXT | grep ^lr.x | wc -l

# Log results for stock ToyBox
$TBSTOCK --version
ls -l | grep $TB | grep -v $TBEXT | grep ^lr.x | rev | cut -d ' ' -f 3 | rev
ls -l | grep $TB | grep -v $TBEXT | grep ^lr.x | wc -l
