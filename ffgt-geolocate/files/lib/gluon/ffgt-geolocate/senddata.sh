#!/bin/sh

# Sent WiFi info once. If geolocation isn't set, or if is_mobile node, fetch location and fill in geoloc data.
if [ ! -e /tmp/run/wifi-data-sent ]; then
# Bloody v4/v6 issues ... From an IPv4-only upstream, the preferred IPv6 AAAA record results in connection errors.
 USEIPV4=1
 USEIPV6=0
 /bin/ping -q -c 3 setup.ipv4.guetersloh.freifunk.net >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  USEIPV4=0
  /bin/ping -q -c 3 setup.guetersloh.freifunk.net >/dev/null 2>&1
  if [ $? -eq 0 ]; then
   USEIPV6=1
  fi
 fi
 if [ $USEIPV4 -eq 1 ]; then
  IPVXPREFIX="ipv4."
 else
  IPVXPREFIX=""
 fi

 mac=`/sbin/uci get network.bat0.macaddr`
 /usr/sbin/iw dev wlan0 scan >/dev/null 2>&1
 if [ $? -ne 0 ]; then
  /sbin/ifconfig wlan0 up
  sleep 2
 fi
 /usr/bin/wget -q -O /dev/null "`/usr/sbin/iw dev wlan0 scan | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk`" && /bin/touch /tmp/run/wifi-data-sent
 curlat="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
 mobile="`/sbin/uci get gluon-node-info.@location[0].is_mobile 2>/dev/null`"
 if [ "X" = "X${curlat}" -o "X${mobile}" = "X1" ]; then
  sleep 10
  /usr/bin/wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}guetersloh.freifunk.net/geoloc.php?list=me&node=$mac"
  if [ -e /tmp/geoloc.out ]; then
   /bin/cat /dev/null >/tmp/geoloc.sh
   haslocation="`/sbin/uci get gluon-node-info.@location[0] 2>/dev/null]`"
   if [ "${haslocation}" != "location" ]; then
    echo "/sbin/uci add gluon-node-info location" >>/tmp/geoloc.sh
   fi
   # Honour existing share_location setting; if missing, create & set to '1'
   hasshare="`/sbin/uci get gluon-node-info.@location[0].share_location 1>/dev/null 2>&1; echo $?`"
   if [ "${hasshare}" != "0" ]; then
    echo "/sbin/uci set gluon-node-info.@location[0].share_location=1" >>/tmp/geoloc.sh
   fi
   /usr/bin/awk </tmp/geoloc.out '/^LAT:/ {printf("/sbin/uci set gluon-node-info.@location[0].latitude=%s\n", $2);} /^LON:/ {printf("/sbin/uci set gluon-node-info.@location[0].longitude=%s\n", $2);} END{printf("/sbin/uci commit gluon-node-info\n");}' >>/tmp/geoloc.sh
   /bin/sh /tmp/geoloc.sh
  fi
 fi
fi
