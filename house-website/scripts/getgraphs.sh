#!/bin/bash
CAMERAPATH=/var/www/house/cameras
GRAPHPATH=/var/www/house/graphs
GRAPHWIDTH=400
CACTIURL=http://web.flarg.net/cacti

# cameras
# /usr/bin/wget -q -O $CAMERAPATH/feeder1.jpg http://82.152.110.111/cgi-bin/jpg/image.cgi
# /usr/bin/wget --user=admin --password=admin -q -O $CAMERAPATH/feeder2.jpg http://82.152.110.117/GetImage.cgi?CH=0
# /usr/bin/wget --user=admin --password= -q -O $CAMERAPATH/frontdoor.jpg http://82.152.110.109/snapshot.cgi

# temperatures
/usr/bin/wget -q -O $GRAPHPATH/temp_combhouse_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=483&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/temp_combhouse_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=483&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/temp_combhouse_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=483&rra_id=2"

/usr/bin/wget -q -O $GRAPHPATH/temp_loft_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=518&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/temp_loft_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=518&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/temp_loft_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=518&rra_id=2"

/usr/bin/wget -q -O $GRAPHPATH/temp_boiler_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=519&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/temp_boiler_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=519&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/temp_boiler_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=519&rra_id=2"

# power
/usr/bin/wget -q -O $GRAPHPATH/power_total_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=520&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/power_total_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=520&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/power_total_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=520&rra_id=2"

# network
/usr/bin/wget -q -O $GRAPHPATH/net_internet_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=699&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/net_internet_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=699&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/net_internet_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=699&rra_id=2"

/usr/bin/wget -q -O $GRAPHPATH/net_wifiusers_1min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=698&rra_id=5"
/usr/bin/wget -q -O $GRAPHPATH/net_wifiusers_5min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=698&rra_id=1"
/usr/bin/wget -q -O $GRAPHPATH/net_wifiusers_30min.png "$CACTIURL/graph_image.php?action=view&graph_width=$GRAPHWIDTH&local_graph_id=698&rra_id=2"
