#!/system/bin/sh

# Magisk Module: ToyBox-Ext v1.0.9
# Copyright (c) zgfg @ xda, 2022-
# GitHub source: https://github.com/zgfg/ToyBox-Ext

# Module's own path (local path)
MODDIR=${0%/*}

# Log for debugging
LogFile="$MODDIR/service.log"
exec 3>&2 2>$LogFile 1>&2
set -x
date +%c

# Log Magisk version and magisk --path
magisk -c
magisk --path

# Log ROM A/B info
getprop ro.product.cpu.abi
getprop ro.product.cpu.abilist

# Log results for stock ToyBox
TB=toybox
$TB --version
TBBIN=$(which $TB)
ls -lZ $TBBIN
TBDIR=$(echo "$TBBIN" | sed "s,/$TB$,,")
TBEXT=toybox-ext
if [ -d $TBDIR ]
then
  cd $TBDIR
  pwd
  ls -la | grep $TB | grep -v $TBEXT | grep ^lr.x | rev | cut -d ' ' -f 3 | rev
  ls -la | grep $TB | grep -v $TBEXT | grep ^lr.x | wc -l
fi

# Log results for ToyBox-Ext
$TBEXT --version
TBEXTBIN=$(which $TBEXT)
ls -lZ $TBEXTBIN
TBEXTDIR=$(echo "$TBEXTBIN" | sed "s,/$TBEXT$,,")
if [ -d $TBEXTDIR ]
then
  cd $TBEXTDIR
  pwd
  ls -la | grep $TBEXT | grep ^lr.x | rev | cut -d ' ' -f 3 | rev
  ls -la | grep $TBEXT | grep ^lr.x | wc -l
  if [ "$TBEXTDIR" != "$TBDIR" ]
  then
    ls -la | grep $TB | grep -v $TBEXT | grep ^lr.x | rev | cut -d ' ' -f 3 | rev
    ls -la | grep $TB | grep -v $TBEXT | grep ^lr.x | wc -l
  fi
fi

# Source the original toybox binary type and last download time
cd $MODDIR
pwd
TBSCRIPT='./tbtype.sh'
if [ -f $TBSCRIPT ]
then
  . $TBSCRIPT
fi

# Current time
DLTIME=$(date +"%s")

# Passed time since the last download
PASSEDTIME=$(($DLTIME - $LASTDLTIME))

# Waiting time between downloads (15 days)
WAITTIME=$((15 * 24 * 3600))

# If waiting time passed, download the latest binary again
if [ ! -z $TBTYPE ] && [ $PASSEDTIME -gt $WAITTIME ]
then
  # Wait to finish booting
  until [ "$(getprop sys.boot_completed)" = 1 ]
  do
    sleep 1
  done

  # Wait few additional seconds
  sleep 3
  rm -f $TBTYPE
  /data/adb/magisk/busybox wget -c -T 20 "http://landley.net/toybox/bin/$TBTYPE"
fi

# Test the download 
if [ ! -z $TBTYPE ] && [ -f $TBTYPE ]
then
  # Compare checksums for the old and new binary
  MD5Old=$(md5sum toybox-ext | head -c 32)
  MD5New=$(md5sum "$TBTYPE" | head -c 32)
  if [ "$MD5New" = "$MD5Old" ]
  then
    # Save the download time
    echo "LASTDLTIME=$DLTIME" >> $TBSCRIPT

    # Delete, same as old binary
    rm -f $TBTYPE
  else
    # Test downloaded binary
    chmod 755 $TBTYPE
    Applets=$(./$TBTYPE)
    if [ -z "$Applets" ]
    then
      # Delete, not working
      rm -f $TBTYPE
    else
      # Save the binary type and installation time
      echo "TBTYPE=$TBTYPE" > $TBSCRIPT
      echo "LASTDLTIME=$DLTIME" >> $TBSCRIPT

      # Notify user to reboot
      Version=$(./$TBTYPE --version)
      exec 2>&3 3>&-
      su -lp 2000 -c "cmd notification post -S bigtext -t 'ToyBox-Ext Module' 'Tag' 'Reboot to update ToyBox binary to $Version'" 1>/dev/null
	  exec 3>&2 2>>$LogFile 1>&2
    fi
  fi
fi
