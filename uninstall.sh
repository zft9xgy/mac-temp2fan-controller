#!/usr/bin/env bash
# uninstall script

sudo systemctl stop temp2fan.service
sudo systemctl disable temp2fan.service

sudo systemctl stop temp2fan.timer
sudo systemctl disable temp2fan.timer

echo "Stop and disable service and timer.....done"

sudo rm /etc/systemd/system/temp2fan.service
sudo rm /etc/systemd/system/temp2fan.timer
sudo rm /usr/bin/bash/temp2fan-controler.sh

echo "Service, timer and script were deleted.....done"


sudo systemctl daemon-reload
echo "Systemd reload.....done"

# This code will set fans to auto mode.
i=1
for fan in fan*_manual
do
  echo 0 > $fan
  ((i = i + 1))
done

echo "Fans on automatic mode on.....done"


sudo chmod o-w /sys/devices/platform/applesmc.768/fan*_output
sudo chmod o-w /sys/devices/platform/applesmc.768/fan*_manual


echo "Permission reset to original state.....done"

echo "Uninstallation is complete.....done"

