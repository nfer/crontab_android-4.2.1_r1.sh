# crontab_android-4.2.1_r1.sh
my crontab script to update android-4.2.1 code and build all

1. get svn version(both HEAD and BASE)
```Bash
HEAD_VER=`svn log -r HEAD | awk '{if(NR==2)print $1}' | cut -b 2-`
BASE_VER=`svn log -r BASE | awk '{if(NR==2)print $1}' | cut -b 2-`
```
2. update code and revert modification
```Bash
svn up --force > $BUILD_LOG
svn st -q | grep ^M | grep -v $NONEED_TO_REVERT | awk '{print $2}' | xargs -i svn revert {} >> $BUILD_LOG
```
3. envsetup and build all
```Bash
source build/envsetup.sh >> $BUILD_LOG
make >> $BUILD_LOG 2>& 1
```