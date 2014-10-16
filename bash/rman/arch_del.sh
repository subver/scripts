#!/usr/bin/bash

#30 2 * * *  del_archlog.sh > /dev/null 2>&1
##
. ~/.profile
export LANG=zh_CN.gb2312

##
CURDATE=`date +%Y%m%d`
CURTIME=`date +%H%M%S`
CURHOST=`hostname`

LOGDIR=${HOME}/log
LOGFILENAME=${CURHOST}_${CURDATE}_${CURTIME}.txt
LOGFILE=${LOGDIR}/${LOGFILENAME}

##########################################################
exec 6>&1
exec > ${LOGFILE}

rman target / << EOF
delete noprompt archivelog all;
exit
EOF

##########################################################
exec 1>&6 6>&-

exit 0