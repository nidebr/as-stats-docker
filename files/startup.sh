#!/bin/bash

# build argument list for asstatd.pl
args=()
if [[ $NETFLOW == 1 ]] ; then
  # NetFlow is enabled by default, running on a default port so we don't need to add command line to enable it
  if [[ -v NETFLOW_PORT ]] ; then
    # Set NetFlow port if a custom port is required
    args+=("-p" "$NETFLOW_PORT")
  fi
else
  # Disable NetFlow
  args+=("-p" "0")
fi

if [[ $SFLOW == 1 ]] ; then
  # sFlow is enabled by default, running on a default port so we don't need to add command line to enable it
  if [[ -v SFLOW_PORT ]] ; then
    # Set sFlow port if a custom port is required
    args+=("-P" "$SFLOW_PORT")
  fi

  # Own AS Number is required for sflow
  args+=("-a" "$SFLOW_ASN")

  # Enable peer-as statistics if requested
  if [[ $SFLOW_PEERAS == 1 ]] ; then
    args+=("-n")
  fi
else
  # Disable sFlow
  args+=("-P" "0")
fi

# Enable IP<->ASN mapping with provided JSON file path
if [[ -v IP2AS_PATH ]]; then
  args+=("-m" "$IP2AS_PATH")
fi

# lance AS-Stats
nohup /root/AS-Stats/bin/asstatd.pl -r /data/as-stats/rrd -k /data/as-stats/conf/knownlinks "${args[@]}" &

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
