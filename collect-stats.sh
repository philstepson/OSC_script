#!/bin/bash
# Begin collect-stats.sh for Linux
# (c) 2019 Oracle Solution Center - Benoit
  
DAT="`date +%Y%m%d`"
HST="`hostname`"
HOUR="`date +%H`"
DIR="/tmp/stats/${HST}/${DAT}_${HOUR}"
DELAY=15
COUNT=40
# Create directory if needed
if ! test -d ${DIR}
then
        /bin/mkdir -p ${DIR}
fi
echo Stats script started in $DIR for $DELAY x $COUNT seconds
# configuration
date >${DIR}/THE_START
uname -a >${DIR}/UNAME
cat /proc/cpuinfo >CPU
cat /proc/meminfo >MEM
cat /etc/sysctl.conf >SYS
df -k >${DIR}/DF
# general check
export TERM=linux
/usr/bin/top -b -d ${DELAY} -n ${COUNT} > ${DIR}/top_${DAT}.log 2>&1 &
# cpu check
/usr/bin/sar -u ${DELAY} ${COUNT} > ${DIR}/cpu_${DAT}.log 2>&1 &
/usr/bin/mpstat -P all ${DELAY} ${COUNT} > ${DIR}/mpstat_${DAT}.log 2>&1 &
# memory check
/usr/bin/vmstat ${DELAY} ${COUNT} > ${DIR}/vmstat_${DAT}.log 2>&1 &
# I/O check
/usr/bin/iostat ${DELAY} ${COUNT} > ${DIR}/iostat_${DAT}.log 2>&1 &
# network check
/usr/bin/sar -n DEV ${DELAY} ${COUNT} > ${DIR}/net_${DAT}.log 2>&1 &
wait
echo Stats script done
date >${DIR}/THE_END
echo Create Tar file
tar cvf - /tmp/stats |gzip >stats-${HST}.tar.g
#End of Stats collection script