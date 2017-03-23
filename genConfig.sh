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
find $PWD/data/labels | grep [1-9].txt > $TRAIN_LOCATION
find $PWD/data/labels | grep 0.txt > $TEST_LOCATION
echo "Done."
echo ""


echo "Generating obj.names ..."
ls -l ./data/labels/ | grep ^d > cfg/label.bak
awk '{ print $9}' cfg/label.bak > $NAMES_LOCATION
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


echo "Downloading pre-trained network ..."
if [ ! -s $NEURAL_LOCATION ]; then
    wget -O $NEURAL_LOCATION http://pjreddie.com/media/files/darknet19_448.conv.23
else
    echo "Pre-trained network already downloaded."
fi
echo "Done."
echo ""


echo "Configs files generated you can now run this in the Darknet folder"
echo "./darknet detector train $DATA_LOCATION $CFG_LOCATION $PWD"
