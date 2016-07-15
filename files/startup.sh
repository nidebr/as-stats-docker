#!/bin/bash

# lance AS-Stats
if [[ $NETFLOW == 1 && $SFLOW != 1 ]] ; then
  nohup /root/AS-Stats/bin/asstatd.pl -r /data/as-stats/rrd -k /data/as-stats/conf/knownlinks -P0 -p $NETFLOW_PORT &
elif [[ $SFLOW == 1 && $NETFLOW != 1 ]] ;  then
  nohup /root/AS-Stats/bin/asstatd.pl -r /data/as-stats/rrd -k /data/as-stats/conf/knownlinks -P $SFLOW_PORT -a $SFLOW_ASN -p 0 &
elif [[ $NETFLOW == 1 && $SFLOW == 1 ]] ;  then
  nohup /root/AS-Stats/bin/asstatd.pl -r /data/as-stats/rrd -k /data/as-stats/conf/knownlinks -P $SFLOW_PORT -a $SFLOW_ASN -p $NETFLOW_PORT &
fi

# Mise à l'heure
if [ -n $TZ ] ; then
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
else
  cp /usr/share/zoneinfo/UTC /etc/localtime
  echo UTC > /etc/timezone
fi

# persistante config file web ui
if [ -f /data/as-stats/config.inc ] ; then
  rm /var/www/config.inc
  ln -s /data/as-stats/config.inc /var/www/config.inc
else
  mv /var/www/config.inc /data/as-stats/config.inc
  ln -s /data/as-stats/config.inc /var/www/config.inc
fi

# start first data to generate asstats_day.txt - wait 2 minutes
sleep 120
/root/AS-Stats/bin/rrd-extractstats.pl /data/as-stats/rrd /data/as-stats/conf/knownlinks /data/as-stats/asstats_day.txt
