#/bin/sh

CFG_LOCATION="$PWD/cfg/yolo-sort.cfg"
NAMES_LOCATION="$PWD/cfg/obj.names"
DATA_LOCATION="$PWD/cfg/obj.data"
TRAIN_LOCATION="$PWD/cfg/train.txt"
TEST_LOCATION="$PWD/cfg/test.txt"
NEURAL_LOCATION="$PWD/cfg/darknet19_448.conv.23"


echo "Calculating number of classes and filters ..."
CLASSES=`ls -l ./data/labels/ | grep -c ^d`
FILTERS="$((($CLASSES+5)*5))"

echo "Classes: $CLASSES"
echo "Filters: $FILTERS"
echo ""


echo "Generating $CFG_LOCATION ..."
cp -f ./templates/yolo-sort.cfg $CFG_LOCATION
sed -i.bak "s/<classes>/$CLASSES/" $CFG_LOCATION
sed -i.bak "s/<filters>/$FILTERS/" $CFG_LOCATION
echo "Done."
echo ""


echo "Generating train and test set ..."
# This is a cheap way to split data
find $PWD/data/images | grep --include=*.{jpg,JPG} [1-9]\\. > $TRAIN_LOCATION
find $PWD/data/images | grep --include=*.{jpg,JPG} [0]\\. > $TEST_LOCATION
echo "Done."
echo ""


echo "Generating obj.names ..."
ls -l ./data/classes/ | tail --line=+2  > cfg/label.bak
awk '{ print $11}' cfg/label.bak | cut -f1 -d'.' > $NAMES_LOCATION

echo "Classes found:"
cat $NAMES_LOCATION
echo "Done."
echo ""


echo "Generating obj.data ..."
cp -f ./templates/obj.data $DATA_LOCATION
sed -i.bak "s/<classes>/$CLASSES/" $DATA_LOCATION
sed -i.bak "s,<train_location>,$TRAIN_LOCATION," $DATA_LOCATION
sed -i.bak "s,<test_location>,$TEST_LOCATION," $DATA_LOCATION
sed -i.bak "s,<names_location>,$NAMES_LOCATION," $DATA_LOCATION
echo "Done."
echo ""

rm cfg/*.bak


echo "Backup older Darknet configuration ..."
mv -f /usr/src/darknet/yolo-sort.cfg /usr/src/darknet/yolo-sort.cfg-old


echo "Copying configs to Darknet installation ..."
cp -f $CFG_LOCATION /usr/src/darknet/
echo "Done."
echo ""


echo "Downloading pre-trained network ..."
if [ ! -s $NEURAL_LOCATION ]; then
    wget -O $NEURAL_LOCATION http://pjreddie.com/media/files/darknet19_448.conv.23
else
    echo "Pre-trained network already downloaded."
fi
echo "Done."
echo ""


echo "Configs files generated you can now run this in the Darknet folder"
echo "cd ../../darknet && ./darknet detector train $DATA_LOCATION $CFG_LOCATION $PWD"
echo "Or test the detector on some data"
echo "cd ../../darknet && ./darknet detect yolo-sort.cfg backup/yolo-sort_4000.weights /usr/src/server/training-data/data/images/cup_paper/IMG_1940.JPG"
