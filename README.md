# AudioShift (DreamOS)

AudioShift lets you watch a live satellite channel while listening to an IP
commentary stream. It provides adjustable audio/video delay, RAM-backed video
timeshift where available, playlist and Xtream source management, and online
EPG mapping for supported channels.

## Install

Run this on the receiver through Telnet or SSH:

```sh
wget -O - https://xfayez95.github.io/audioshift/installer.sh | sh
```

The installer downloads the latest DreamOS package, installs it, and restarts
Enigma2. You will then find **AudioShift** in the Plugin Browser, Extensions
menu, and Audio menu.

### Manual install

```sh
wget https://github.com/xFayez95/audioshift/releases/latest/download/audioshift-dreamos.deb
dpkg -i audioshift-dreamos.deb
systemctl restart enigma2
```
