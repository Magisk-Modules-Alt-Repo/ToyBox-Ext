# Module's own path (local path)
cd $MODPATH

# toybox ARMv7 and higher binaries
TBBinList="
toybox-aarch64
toybox-armv7m
toybox-armv7l
"

# Find the suitable binary
TBFound=""
for TBBin in $TBBinList
do
  if  [ -z $TBFound ]
  then
    chmod 755 $TBBin

    # Test if binary executing 
    Applets=$(./$TBBin)
#    echo $Applets

    if  [ ! -z "$Applets" ]
    then
      # Suitable binary found
      echo "Installing $TBBin binary"
      TBFound=true
      mv $TBBin toybox-ext
      continue
    fi
  fi

  # Delete binary (already found or not executing)
  rm -f $TBBin
done

if  [ -z $TBFound ]
then
  # Suitable binary not found
  echo
  echo ERROR: Not supported platform!
  echo
  getprop | grep 'cpu\.abi'
  echo
  exit -1
fi
