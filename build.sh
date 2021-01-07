#!/bin/bash
#
# Kanged From Inception



# Init Script
ROM_DEVICE=revengeos_tissot
TARGET=userdebug
ROM=ros
DEVICE=Tissot
BUILD_START=$(date +"%s")
FOLDER=$HOME/$ROM
OUT=$FOLDER/out/target/product/tissot

export KBUILD_BUILD_USER="Takeshiro"
export KBUILD_BUILD_HOST="TakeshiroCI"

TOKEN=""
CHAT_ID=""
TYPE="RevengeOS"

# Color Code Script
black='\e[0;30m'        # Black
red='\e[0;31m'          # Red
green='\e[0;32m'        # Green
yellow='\e[0;33m'       # Yellow
blue='\e[0;34m'         # Blue
purple='\e[0;35m'       # Purple
cyan='\e[0;36m'         # Cyan
white='\e[0;37m'        # White
nocol='\033[0m'         # Default

# Tweakable Stuff

#COMPILATION SCRIPTS


echo -e "${green}"
echo "--------------------------------------------------------"
echo "      Cleaning environment     "
echo "--------------------------------------------------------"

cd $FOLDER
rm *.txt
rm *.url
rm $OUT/*.zip
rm $OUT/*.zip.md5sum
rm out/.lock

echo -e "$cyan***********************************************"  
echo "         Setting up Environment     "
echo -e "***********************************************$nocol"

. build/envsetup.sh
lunch $ROM_DEVICE-$TARGET
make installclean

echo -e "$cyan***********************************************"
echo "          Building the Bitch       "
echo -e "***********************************************$nocol"

msg1=$(mktemp)
{
  echo "*Building RevengeOS for Mi A1 (tissot)*"
  echo "*Start Time:* $(date +"%Y-%m-%d"-%H%M)"
  echo "*Build Type:* $TARGET"
  echo "*Android Version:* 11 (R)"
} > "${msg1}"
MESSAGE1=$(cat "$msg1")

curl -s -X POST -d chat_id=$CHAT_ID -d parse_mode=markdown -d text="$MESSAGE1" https://api.telegram.org/bot${TOKEN}/sendMessage
make bacon -j4 | tee log.txt


if ! [ -f $OUT/*$TYPE*.zip ]; then
    echo -e "Build compilation failed, See buildlog to fix errors"
    curl -F chat_id=$CHAT_ID -F document=@"$FOLDER/log.txt" -F caption="@Takeshiro, your build failed. Fix it now or get some help." https://api.telegram.org/bot${TOKEN}/sendDocument
    exit 1
fi

# If compilation was successful

echo -e "$green***********************************************"
echo "          UPLOADING    "
echo -e "***********************************************$nocol"

gdrive upload -p folderidhere $OUT/*$TYPE*.zip | tee -a gdrive-up.txt


echo -e "$green***********************************************"
echo "          Fetching info    "
echo -e "***********************************************$nocol"

FILEID=$(cat gdrive-up.txt | tail -n 1 | awk '{ print $2 }')
gdrive share $FILEID
gdrive info $FILEID | tee -a gdrive-info.txt
MD5SUM=$(cat gdrive-info.txt | grep 'Md5sum' | awk '{ print $2 }')
NAME=$(cat gdrive-info.txt | grep 'Name' | awk '{ print $2 }')
SIZE=$(cat gdrive-info.txt | grep 'Size' | awk '{ print $2 }')
DLURL=$(cat gdrive-info.txt | grep 'DownloadUrl' | awk '{ print $2 }')
LINKBUTTON="$DLURL"

echo -e "$green***********************************************"
echo "          Copied Successfully        "
echo -e "***********************************************$nocol"



# BUILD TIME
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))


msg=$(mktemp)
{
  echo "*BUILD SUCCESS!* $DIFF"
  echo "*Link:* https://test.takeshiro.workers.dev/0:/RevengeOS/"
  echo "*NOTE: ONLY TESTERS HAVE ACCESS TO THIS LINK! DO NOT ASK FOR PASSWORD!*"
} > "${msg}"
MESSAGE=$(cat "$msg")


curl -s -X POST -d chat_id=$CHAT_ID -d parse_mode=markdown -d text="$MESSAGE" https://api.telegram.org/bot${TOKEN}/sendMessage
curl -F chat_id=$CHAT_ID -F document=@"$FOLDER/log.txt" -F caption="log" https://api.telegram.org/bot${TOKEN}/sendDocument
#END
