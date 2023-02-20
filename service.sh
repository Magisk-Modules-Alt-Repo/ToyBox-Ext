#!/system/bin/sh

# Magisk Module: ToyBox-Ext v1.0.5
# Copyright (c) zgfg @ xda, 2022-
# GitHub source: https://github.com/zgfg/ToyBox-Ext

# Wait to finish boot
until [ "$(getprop sys.boot_completed)" = 1 ]
do
  sleep 1
done

# Module's own path (local path)
MODDIR=${0%/*}
cd $MODDIR

# Current time
DLTIME=$(date +"%s")

# Read the original toybox binary type and last download time
source tbtype.sh

# Passed time since the last download
PASSEDTIME=$(($DLTIME - $LASTDLTIME))

# Waiting time between downloads (15 days)
WAITTIME=$((15 * 24 * 3600))

# If waiting time passed, download the latest binary again
if [ ! -z $TBTYPE ] && [[ $PASSEDTIME -gt $WAITTIME ]]
then
  rm -f $TBTYPE
  wget -c "http://landley.net/toybox/bin/$TBTYPE"
fi

# Test the download 
if [ -e $TBTYPE ]
then
  chmod 755 $TBTYPE
  Applets=$(./$TBTYPE)
  if [ ! -z "$Applets" ]
  then
    # Save the toybox binary type and installation time
    echo "TBTYPE=$TBTYPE" > tbtype.sh
    echo "LASTDLTIME=$DLTIME" >> tbtype.sh
  else
    # Delete, not working
    rm -f $TBTYPE
  fi
fi
