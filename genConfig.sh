#!/bin/sh
BACKUP_LOCATION="$PWD/cfg/"

DARKNET_LOCATION="/usr/src/darknet"
CFG_LOCATION="$DARKNET_LOCATION/yolo-sort.cfg"

DATA_LOCATION="$DARKNET_LOCATION/voc-sort.data"
TRAIN_LOCATION="$DARKNET_LOCATION/data/train.txt"
TEST_LOCATION="$DARKNET_LOCATION/data/test.txt"
NAMES_LOCATION="$DARKNET_LOCATION/data/sort.names"

NEURAL_LOCATION="$DARKNET_LOCATION/darknet19_448.conv.23"

echo "################################################################################"
echo "# Creating configurations for Yolo                                             #"
echo "################################################################################"
echo ""

echo "# Calculating number of classes and filters ..."
echo "################################################################################"
CLASSES=`find ./data/classes/ -type f | wc -l`
FILTERS="$((($CLASSES+5)*5))"

echo "Classes: $CLASSES"
echo "Filters: $FILTERS"
echo ""


echo "Replacing template in $CFG_LOCATION ..."
cp -f ./templates/yolo-sort.cfg $CFG_LOCATION
sed -i.bak "s/<classes>/$CLASSES/" $CFG_LOCATION
sed -i.bak "s/<filters>/$FILTERS/" $CFG_LOCATION
echo "Done."
echo ""


echo "# Generating train and test set ..."
echo "################################################################################"
# This is a cheap way to split data
find $PWD/data/images | grep --include=*.{jpg,JPG} [1-9]\\. > $TRAIN_LOCATION
find $PWD/data/images | grep --include=*.{jpg,JPG} [0]\\. > $TEST_LOCATION

NB_TRAIN=`cat $TRAIN_LOCATION | wc -l`
NB_TEST=`cat $TEST_LOCATION | wc -l`

echo "Number of picture for training: $NB_TRAIN"
echo "Number of picture for testing: $NB_TEST"
echo ""

echo "Done."
echo ""


echo "# Generating obj.names (possible classes) ..."
echo "################################################################################"
ls -l ./data/classes/ | tail --line=+2  > cfg/label.bak
awk '{ print $11}' cfg/label.bak | cut -f1 -d'.' > $NAMES_LOCATION

echo "Classes found:"
cat $NAMES_LOCATION
echo ""
echo "Done."
echo ""


echo "# Generating obj.data ..."
echo "################################################################################"
cp -f ./templates/obj.data $DATA_LOCATION
sed -i.bak "s/<classes>/$CLASSES/" $DATA_LOCATION
sed -i.bak "s,<train_location>,$TRAIN_LOCATION," $DATA_LOCATION
sed -i.bak "s,<test_location>,$TEST_LOCATION," $DATA_LOCATION
sed -i.bak "s,<names_location>,$NAMES_LOCATION," $DATA_LOCATION
echo "Done."
echo ""

rm cfg/*.bak


echo "# Copying configs to training folder ..."
echo "################################################################################"
cp -f $CFG_LOCATION $BACKUP_LOCATION
cp -f $DATA_LOCATION $BACKUP_LOCATION
cp -f $NAMES_LOCATION $BACKUP_LOCATION
echo "Done."
echo ""
echo " NOTES"
echo "  - Files in $BACKUP_LOCATION are copies modifying them will not change what Yolo will use!"
echo "  - Path are suppose to be corresponding on how you will run Darknet (e.g. /usr/src/darknet/ if run within Docker)"
echo ""


echo "# Downloading pre-trained network ..."
echo "################################################################################"
if [ ! -s $NEURAL_LOCATION ]; then
    echo "Pre-trained network not found. Downloading"
    wget -O $NEURAL_LOCATION http://pjreddie.com/media/files/darknet19_448.conv.23
else
    echo "Pre-trained network already downloaded."
fi
echo "Done."
echo ""
echo ""


echo "################################################################################"
echo "# Configs are generated"
echo "################################################################################"
echo ""
echo "You can now run this in the Darknet folder"
echo "    cd $DARKNET_LOCATION"
echo "    ./darknet detector train $DATA_LOCATION $CFG_LOCATION $PWD"
echo ""
echo "Or test the detector on some data (if you've already train)"
echo "cd ../../darknet && ./darknet detect yolo-sort.cfg <weights> <image_location>"
echo ""
