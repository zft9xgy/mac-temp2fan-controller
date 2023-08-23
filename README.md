# iMac temp2fan controler

temp2fan is a daemon that reads the maximum temperature of the applesmc module and adjusts the fan speed according to a driver.

Originally created for an imac because it supports multiple fans, but it is possible to use it on any mac with the applesmc kernel module.

If you have any questions, find bugs, or think you can improve, feel free to open an issue or email me at brujula.viene.0d@icloud.com

## The reason for this script

TL;DR

Due to the fact that apple limits the updates of the devices after a while, I decided to install linux (i use arch btw) on my old iMac late 2009 to give it a new life. I quickly noticed that the fans were running at full speed and were not regulated properly.

I did some research until I ended up installing mbpfan which you probably already know about. There are other developments out there but most of them were made for Macbooks, which apparently only have one fan.

After installing mbpfan the fans were regulated to the minimum, which was a relief at first, but after a short time of use, I noticed that it wasn't going well at all. It seems that no matter how much I modified the config file, the fan control didn't seem to work properly.

After investigating, I think that the "error" or the reason why mbpfan doesn't work correctly in the iMac is because it takes the coretemp temperature, which i dont know why, it doesnt reflect the correct temperature to my iMac.

I tried to modify the code of mbpfan and adapt it but I lack knowledge of C at the moment. So, after a while I decided to make my own iMac controller with a simple script, which takes into account the applesmc temperatures and regulates the 3 fans of the iMac at the same time (hdd,cpu odd).

## Purpose of the script

This script makes use of the `sensors` command and takes all the applesmc temperatures starting with 'T'. It selects from these temperatures the maximum of them and based on this it performs a discrete control over the fans that follows the following scheme.

- temp_max <65 fan_rpm -> min
- temp_max > 65 fan_rpm -> 25%
- temp_max > 70 fan_rpm -> 50%
- temp_max > 75 fan_rpm -> 75%
- temp_max > 80 fan_rpm -> 85%
- temp_max > 85 fan_rpm -> max

This script takes into account all the fans (in the case of my iMac, 3 fans) and sets the rpm by percentage for all of them.

Example: If you have a maximum temperature of 72 degrees, either in the CPU or the GPU or in any of the sensors, the controller will set the fans to 50%, calculating for each one its corresponding rpm.

## Prerequisites and initial check

This script makes use of the `sensors` command, which is usually loaded by default in many linux distributions.

To check that you have it installed, just type `sensors` in the terminal and the result should look something like this.

This script makes use of the `sensors` command, which is usually loaded by default in many linux distributions.

To check that you have it installed, just type `sensors` in the terminal and the result should look something like this.

If you don't have it installed, install the `lm-sensors` package.

```bash
# Ubuntu
$ sudo apt install lm-sensors

# Arch linux
$ sudo pacman -Sy lm_sensors
```

- Ubuntu ref: https://www.cyberciti.biz/faq/install-sensors-lm-sensors-on-ubuntu-debian-linux/
- Arch Wiki: https://wiki.archlinux.org/title/lm_sensors

On the other hand, you can check if you have the applesmc kernel loaded with the following code.

```bash
$ cd /sys/devices/platform/applesmc.768
$ ls -1
```

You should have a list of temperature and fan files.
-> insert screenshot here

## Incopatibilities

As this is a first version I haven't found any incompatibilities yet, but possibly other daemons that try to control the temperature may cause conflicts with this one... if possible disable daemons like mbpfan or macfanltd or similar.

## Install

```bash
$ git clone dir
$ cd imac-temp2fan/
$ sh install.sh
```

The script will ask you for the password because some of the commands require it. It is explained why a password is required when running the script, but you can also review the script before installing it.

## Usage

After installation you don't have to do anything else, it should be enough to have the service and the timer running in the background. The script runs every 5 seconds.

If you want to change the refresh time of the script, before the installation go to the file 'temp2fan.timer" and modify the section

```bash
[Timer]
OnUnitActiveSec=5
```

Replace the 5 with as many seconds as you want.

## Functional check

To check that the script is working, you can check it in several ways.

Checking if both the service and the timer are loaded and active in systemd.

```bash
$ systemctl status temp2fan.service
$ systemctl status temp2fan.timer
```

Checking the real time execution from `journalctl` with the following command

```bash
$ journalctl -u temp2fan -f
```

Finally checking with the `sensors` command that everything is working as expected.

If it doesn't work for you or you detect any anomaly in the execution, I'll be happy to take a look at it, you can open an issue or send an email to brujula.viene.0d@icloud.com

## Uninstall

If after installing it doesn't work, you have found a better controller or you just want to uninstall it, I provided a script that undoes everything that the install script does.

## References

Thanks to all who have contributed to the mbpfan project and to allanmcrae for that blog post.

https://ineed.coffee/project/mbpfan
http://allanmcrae.com/2010/05/simple-macbook-pro-fan-daemon/
https://github.com/linux-on-mac/mbpfan

## Todos / Features to implement

Just a list of ideas that could be potential to implement

### TO-DO

- cure content and add comments to the scripts
- add screenshots
- double check on readme and cure info

### Features ideas

- change the temperature gathering system, use the applesmc module files instead of grep sensors
- add the option to choose which type of kernel module to take as input (applesmc or coretemp) or take all or specify which applesmc module to take
- modify main controller to add a continuous option like the allanmcrae controller
- add a .config so that the user can choose their temperature ranges
  -- such as for example refresh time and temperature ranges
- give the option to control each fan separately.
- prepare a script that collects logs for debugging so that when it doesn't work for someone they can use the script to simplify.
- prepare a manual to explain how the controller works for newbies.
