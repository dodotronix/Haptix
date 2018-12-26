## HAPTIX

### INSTALL
* install Archlinux on SD card (https://archlinuxarm.org/platforms/armv6/raspberry-pi)
* turn on RPi
* use ssh or keyboard and display to continue in installation

* update system with
> pacman -Syu
* download 
> pacman -S python 
* download snap shot from link: https://aur.archlinux.org/packages/python-spidev/
* open terminal -> cd /path/to/file -> tar xzf file-name -> cd file-name ->
makepkg -s -> sudo pacman -U name-of-file.pkg.tar.xz
* copy test.py to raspberry
* cd /path/to/test.py
* chmod +x test.py
* ./test.py
* you select functions in script, which you want to run

### NOTES
* spidev doc (https://github.com/doceme/py-spidev)
* raspberry ssh command: ssh alarm@10.0.4.x, password: "alarm" (custom settings)
* sudo iptables -t nat -vnL
* setup.sh creates nat, starts dhcpcd, launchs ssh (parameters: on/off)
