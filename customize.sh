# Module's own path (local path)
#echo $MODPATH

TBBIN=toybox-armv7m
cd $MODPATH
chmod 755 $TBBIN
Applets=$(./$TBBIN)
#echo $Applets

if [ -z "$Applets" ]
then
  echo
  echo ERROR: Not supported platform!
  echo
  exit -1
fi
