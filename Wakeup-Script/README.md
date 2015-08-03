## Prerequisites ##
  * MAC Address of the device you wish to remotely wake up.
  * Hostname in /etc/hosts
  * /etc/ethers file with a mapping of MAC to host
  * wakeonlan

_This document assumes `ne` (nice editor) is installed and used for text file editing. Of course any other editor will do._

## Add Host to hosts file ##
  1. open hosts file:
```
sudo ne /etc/hosts
```
  1. add new host, for example:
```
192.168.1.11 tank
```

## Add MAC address of device to ethers file ##
  1. Find MAC address:
```
reto@morpheus:~$ arp tank
Address     HWtype  HWaddress           Flags Mask   Iface
tank        ether   00:11:32:08:6b:03   C            eth0
```
  1. open eithers file:
```
sudo ne /etc/ethers
```
  1. add MAC address, for example:
```
00:11:32:08:6b:03 tank
```

## Install wakeonlan ##
`sudo apt-get install wakeonlan`

## Test ##
Send WoL magic packet:
```
wakeonlan tank
```