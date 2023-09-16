#!/usr/bin/env bash

echo "The next actions will be executed:"
echo " - copy temp2controler to /usr/bin/bash"
echo " - copy config file to /etc/temp2fan.conf"
echo " - copy the temp2fan.service and temp2fan.timer to /etc/systemd/system"
echo " - reload systemd"
echo " - start and enable systemd service"

# copy config to etc
sudo cp temp2fan.conf /etc

# copy service and timer to the corresponding folder
sudo cp temp2fan-controler.sh /usr/bin/
echo "Copy temp2fan.controler.sh to /usr/bin/.......done"

sudo cp temp2fan.service /etc/systemd/system/ && sudo cp temp2fan.timer /etc/systemd/system/
echo "Copy temp2fan.service and temp2fan.timer to /etc/systemd/system/.......done"

# reload systemctl to be able to start and enable
sudo systemctl daemon-reload

#start and enable service
sudo systemctl start temp2fan.service
sudo systemctl enable temp2fan.service

# start and enable timer
sudo systemctl start temp2fan.timer
sudo systemctl enable temp2fan.timer

echo "Start and enable servide and timer.......done"

sudo chmod o+w /sys/devices/platform/applesmc.768/fan*_output
sudo chmod o+w /sys/devices/platform/applesmc.768/fan*_manual
sudo chmod +x /usr/bin/temp2fan-controler.sh

echo "Permission to write and execute added to corresponding files.......done"

# This code will set fans to manual mode.
i=1
for fan in /sys/devices/platform/applesmc.768/fan*_manual
do
  echo 1 > $fan
  ((i = i + 1))
done

echo "Manual mode fans on.......done"
echo "The installation is complete.."