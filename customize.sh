# Module's own path (local path)
cd $MODPATH

# Install to System XBIN if the path exists, otherwise to System BIN path
XBINDIR=/system/xbin
if [ -d $XBINDIR ]
then
  TBDIR=$XBINDIR
else
  TBDIR=/system/bin
fi

# toybox ARMv7 and higher binaries
TBBINList="
toybox-aarch64
toybox-armv7m
toybox-armv7l
"

# Find the suitable binary
TBFound=""
for TBBIN in $TBBINList
do
  if [ -z $TBFound ]
  then
    chmod 755 $TBBIN

    # Test if binary executing 
    Applets=$(./$TBBIN)
#    echo $Applets

    if [ ! -z "$Applets" ]
    then
      # Suitable binary found
      echo "Installing $TBBIN binary and applets to $TBDIR"
      TBFound=true
      mv $TBBIN toybox-ext
      continue
    fi
  fi

  # Delete binary (already found or not executing)
  rm -f $TBBIN
done

if [ -z $TBFound ]
then
  # Suitable binary not found
  echo
  echo ERROR: Not supported platform!
  echo
  getprop | grep 'cpu\.abi'
  echo
  exit -1
fi
