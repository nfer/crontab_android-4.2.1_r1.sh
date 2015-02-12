#! /bin/bash

ANDROID_4_2=~/android-4.2.1_r1
CRONTAB_LOG_FOLDER=~/bak/crontablog
NONEED_TO_REVERT=build/core/main.mk

# mail related variables
MAIL_FOLDER=~/Mail/
CONSIGNEE="nfer.zhuang@gmail.com"
OBJECT="Crontab_build_log"
SIGNATURE="\nNfer Zhuang\nBest Regards\n"

cd $ANDROID_4_2

HEAD_VER=`svn log -r HEAD | awk '{if(NR==2)print $1}' | cut -b 2-`
BASE_VER=`svn log -r BASE | awk '{if(NR==2)print $1}' | cut -b 2-`
DATE=`date "+%Y-%m-%d"`

if [ $HEAD_VER -eq $BASE_VER ]; then
    echo "$DATE: current version($BASE_VER) is the same with svn server($HEAD_VER), no need to build system" >> $CRONTAB_LOG_FOLDER/crontab_log.txt
else
    echo "$DATE: current version($BASE_VER) is different with svn server($HEAD_VER), need to build system" >> $CRONTAB_LOG_FOLDER/crontab_log.txt
    BUILD_LOG=$CRONTAB_LOG_FOLDER/${ANDROID_4_2##*/}_build_$DATE.log
    svn up --force > $BUILD_LOG
    svn st -q | grep ^M | grep -v $NONEED_TO_REVERT | awk '{print $2}' | xargs -i svn revert {} >> $BUILD_LOG
    source build/envsetup.sh >> $BUILD_LOG
    make >> $BUILD_LOG 2>& 1

    # compress BUILD_LOG and send it by mail
    cd $MAIL_FOLDER
    cp $BUILD_LOG ./
    BUILD_LOG_TGZ=`ls *.log | sed 's/log$/tgz/'`
    tar czf $BUILD_LOG_TGZ *.log
    MAIL_CONTENT_FILE=`ls *.log | sed 's/log$/mail/'`
    echo "-----------------comile $HEAD_VER result:-----------------\n" > $MAIL_CONTENT_FILE
    tail $BUILD_LOG >> $MAIL_CONTENT_FILE
    echo $SIGNATURE >> $MAIL_CONTENT_FILE
    mutt -s $OBJECT $CONSIGNEE -a $BUILD_LOG_TGZ < $MAIL_CONTENT_FILE

    # rm unused .tgz and .log file
    rm *.tgz *.log
fi
