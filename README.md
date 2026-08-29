# AudioShift

AudioShift lets you watch a live satellite channel while listening to an IP
commentary stream. It provides adjustable audio/video delay, RAM-backed video
timeshift where available, playlist and Xtream source management, and online
EPG mapping for supported channels.

## Supported images

| Image / receiver type | Package |
| --- | --- |
| DreamOS arm64 | `.deb` |
| OE-Alliance images, Cortex-A15, Python 3.13 | `.ipk` |
| OE-Alliance images, Cortex-A15, Python 3.14 | `.ipk` |
| OE-Alliance images, AArch64, Python 3.14 | `.ipk` |

## Install

Run this on the receiver through Telnet or SSH:

```sh
wget -O - https://xfayez95.github.io/audioshift/installer.sh | sh
```

The installer detects DreamOS or an OE-Alliance IPK receiver, its architecture, and Python
version. It downloads the matching latest package, verifies OpenATV package
integrity, installs it, and restarts Enigma2. You will then find
**AudioShift** in the Plugin Browser, Extensions menu, and Audio menu.

Install without restarting Enigma2 automatically:

```sh
wget -O - https://xfayez95.github.io/audioshift/installer.sh | sh -s -- --no-restart
```

## Manual install

### DreamOS arm64

```sh
wget https://github.com/xFayez95/audioshift/releases/latest/download/audioshift-dreamos.deb
dpkg -i audioshift-dreamos.deb
systemctl restart enigma2
```

### OE-Alliance IPK images

Download the IPK matching both your receiver architecture and Python version
from the [latest release](https://github.com/xFayez95/audioshift/releases/latest),
then install it:

```sh
opkg install --force-reinstall /tmp/enigma2-plugin-extensions-audioshift-<version>-<architecture>-py3.<version>.ipk
init 4
sleep 1
init 3
```

Check the required variant before downloading:

```sh
uname -m
python3 -V
opkg print-architecture
```
