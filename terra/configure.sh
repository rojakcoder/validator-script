#!/bin/bash

# Run the terrad service
echo -n "Installing terrad..."
cp sample/terrad.service /etc/systemd/system/
echo " done"

echo -n "Installing Price Server..."
PRICE_SERVER_PATH=/home/terrau/oracle-feeder/price-server
sudo cp sample/price-server-start.sh $PRICE_SERVER_PATH/
chown terrau:terrau $PRICE_SERVER_PATH/price-server-start.sh
chmod a+x $PRICE_SERVER_PATH/price-server-start.sh
sudo cp sample/price-server.service /etc/systemd/system/
echo " done"

echo -n "Installing Oracle Feeder..."
FEEDER_PATH=/home/terrau/oracle-feeder/feeder
cp sample/feeder-start.sh $FEEDER_PATH/
chown terrau:terrau $FEEDER_PATH/feeder-start.sh
chmod a+x $FEEDER_PATH/feeder-start.sh
sudo cp sample/feeder.service /etc/systemd/system/

sudo systemctl daemon-reload
#sudo systemctl enable terrad
#sudo systemctl enable price-server
#sudo systemctl enable feeder
#sudo systemctl start terrad
#sudo systemctl start price-server
# Run journalctl -f to watch the logs.
