AS-Stats Docker
===============

A tool writted by Manuel Kasper <mk@neon1.net> for Monzoon Networks AG.

This tool generate per-AS traffic graphs from NetFlow/SFlow records.


See [AS-Stats Repository](https://github.com/manuelkasper/AS-Stats) for more details.

### Screenshot
![AS-Stats Screenshot](https://github.com/nidebr/as-stats-docker/raw/master/docs/images/as-stats.png "AS-Stats Screenshot")

How to
------

## Before to launch docker image
### Persistante data
Before to use it, make a right directory for persistante data.

    mkdir -p /data/conf /data/rrd

Create a "knownlinks" file in /data/conf/

See [AS-Stats Repository](https://github.com/manuelkasper/AS-Stats/blob/master/README.md#installation) for more details.

__Example :__

    touch /data/conf/knownlinks
    vim /data/conf/knownlinks

    <ip router> <tab> <ifindex> <tab> <short tag> <tab> <description> <tab> <color digit> <tab> <sampling rate>
    1.1.1.1 <tab> 10 <tab> provider <tab> My Prodiver <tab> 7648EC <tab> 1

__Important: you must use tabs, not spaces, to separate fields!__  

## Variables

### For Netflow

    NETFLOW           set 1 if you want enable Netflow
    NETFLOW_PORT      set udp port for Netflow daemon

### For SFlow

    SFLOW             set 1 if you want enable SFlow
    SFLOW_PORT        set udp port for SFlow daemon
    SFLOW_ASN         set your asn number for SFlow daemon
    SFLOW_PEERAS      set 1 if you want enable peer-as statistics

### IP<->ASM mapping

    IP2AS_PATH        set to path (inside container) containing JSON file for IP<->ASN mapping

### TimeZone

    TZ                 set timezone  

__Important: Default timezone is UTC !__  

## Docker CLI

# For Netflow

    docker run -d --name=as-stats -e NETFLOW=1 -e NETFLOW_PORT=5000 -e TZ=Europe/Paris -v <my directory>:/data/as-stats -p 80:80 -p 5000:5000/udp nidebr/as-stats

__Important: Change WebUI port and Netflow port according your configuration!__


# For SFlow

    docker run -d --name=as-stats -e SFLOW=1 -e SFLOW_PORT=6000 -e SFLOW_ASN=1234 -e TZ=Europe/Paris -v <my directory>:/data/as-stats -p 80:80 -p 5000:5000/udp nidebr/as-stats

__Important: Change WebUI port, SFlow port and ASN number according your configuration!__

## Docker Compose

Docker compose file exemple :

    version: '2'

    services:
     as-stats:
      image: nidebr/as-stats
      ports:
       - "8080:80"
       - "5000:5000/udp"
      environment:
       - NETFLOW=1
       - NETFLOW_PORT=5000
       - TZ=Europe/Paris
      volumes:
       - <my directory>:/data/as-stats

## Config file for web UI

Config file for WebUI a here :

    vim <my directory>/config.inc

See [AS-Stats Repository](https://github.com/manuelkasper/AS-Stats) for more details.

### Launch manually stats day

    docker exec -it as-stats stats-day

__Important: When docker image start, startup script wait 2 minutes and launch automaticaly this script. I recommand wait ~5/10 minutes and restart "manually stats day", its for the first stats appear on WebUI.__

### Bash access

If you want to enter instance :

    docker exec -it as-stats bash
