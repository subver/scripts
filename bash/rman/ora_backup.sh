#!/usr/bin/bash

set -e

#############################################################
# sunday incremental level 0
# other day incremental level 1
#############################################################

. ~/.profile
export LANG=zh_CN.gb2312

##
WEEKDAY=`date +%a`
CURDATE=`date +%Y%m%d`
CURTIME=`date +%H%M%S`
CURHOST=`hostname`

case "${WEEKDAY}" in
    "Sun")
        INC_LEVEL=0
        ;;
    "Tue")
        INC_LEVEL=0
        ;;
    *)
        INC_LEVEL=1
        ;;
esac

LOGDIR=${HOME}/log
LOGFILENAME=${CURHOST}_${CURDATE}_${CURTIME}.rman
LOGFILE=${LOGDIR}/${LOGFILENAME}

##########################################################
exec 6>&1
exec > ${LOGFILE}

rman target / << EOF
run {
    configure backup optimization on;
    configure archivelog deletion policy to applied on standby;
    configure retention policy to redundancy 2;
    configure controlfile autobackup on;

    allocate channel ch1 device type sbt;
    allocate channel ch2 device type sbt;
    allocate channel ch3 device type sbt;
    backup incremental level ${INC_LEVEL} database plus archivelog delete all input;

    release channel ch1;
    release channel ch2;
    release channel ch3;
}

crosscheck backup;
delete noprompt obsolete;

delete noprompt archivelog all completed before 'sysdate-1';
exit

EOF

##########################################################
exec 1>&6 6>&-

exit 0