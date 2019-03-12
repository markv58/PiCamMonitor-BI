#!/bin/bash

cd /home/pi
mkdir /home/pi/cgi-bin
sudo cp -a ~/PiCamMonitor-BI/. ~/cgi-bin/
sudo chmod +x -R /home/pi/cgi-bin
sudo rm /home/pi/cgi-bin/README.md
sudo rm /home/pi/cgi-bin/install.sh
sudo mv /home/pi/cgi-bin/CameraSRV.py /home/pi/
mkdir /home/pi/.config/autostart
sudo cp /home/pi/PiCamMonitor-BI/cameraSRV.desktop /home/pi/.config/autostart
sleep 2s
sudo reboot
