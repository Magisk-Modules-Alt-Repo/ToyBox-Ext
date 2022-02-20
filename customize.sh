# Module's own path (local path)
#echo $MODPATH

# System XBIN path
XBINDIR=/system/xbin

# Local XBIN and (or) BIN paths for mounting
TBXBINDIR=$MODPATH$XBINDIR
TBBINDIR=$MODPATH/system/bin

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

# Install toybox binary
mkdir -p $TBDIR
cd $TBDIR
TBBIN=toybox-armv7m
mv $MODPATH/$TBBIN .
chmod 755 $TBBIN
Applet=toybox
#  Create toybox symlink if toybox not already found in the path
Check=$(which $Applet)
if [ -z "$Check" ]
then
  ln -s $TBBIN $Applet
fi

#  Create symlinks for toybox applets
Applets=$(./$TBBIN)
#echo $Applets
for Applet in $Applets
do
  # Skip if applet already found in the path
  Check=$(which $Applet)
  if [ -z "$Check" ]
  then
    ln -s $TBBIN $Applet
  fi
done
