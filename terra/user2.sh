#!/bin/bash

echo -n "Installing terrad..."
sudo cp -i sample/terrad.service /etc/systemd/system/
sudo sed -i -e 's/$USER/'"$USER"'/' /etc/systemd/system/terrad.service
echo "  done."

sudo systemctl daemon-reload
sudo systemctl enable terrad