#!/bin/bash

# Run the terrad service
echo -n "Installing terrad..."
sudo cp sample/terrad.service /etc/systemd/system/
echo " done"

echo -n "Installing Price Server..."
PRICE_SERVER_PATH=/home/$TERRA_USER/oracle-feeder/price-server
cp sample/price-server-start.sh $PRICE_SERVER_PATH/
chown $TERRA_USER:$TERRA_USER $PRICE_SERVER_PATH/price-server-start.sh
chmod a+x $PRICE_SERVER_PATH/price-server-start.sh
sudo cp sample/price-server.service /etc/systemd/system/
echo " done"

echo -n "Installing Oracle Feeder..."
FEEDER_PATH=/home/$TERRA_USER/oracle-feeder/feeder
cp sample/feeder-start.sh $FEEDER_PATH/
sudo chown $TERRA_USER:$TERRA_USER $FEEDER_PATH/feeder-start.sh
chmod a+x $FEEDER_PATH/feeder-start.sh
sudo cp sample/feeder.service /etc/systemd/system/
echo " done"

sudo systemctl daemon-reload
#sudo systemctl enable terrad
#sudo systemctl enable price-server
#sudo systemctl enable feeder
#sudo systemctl start terrad
#sudo systemctl start price-server
# Run journalctl -f to watch the logs.
