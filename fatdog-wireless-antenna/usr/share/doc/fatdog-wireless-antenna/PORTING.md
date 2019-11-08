**Porting to Other Linux**

Essentially you need to change function `call_restart_network` in
`usr/sbin/fatdog-wireless-antenna.sh` for your Linux distro. Also, if your
distro doesn't include `/bin/dash`, change the first line to a supported shell
she-bang (`#!/bin/sh` will likely work).

Optionally change the icon for the "Restart Network" button in file
`usr/share/icons/hicolor/scalable/apps`. As distributed, this is the
`wpa_gui.svg` icon because Fatdog64-710 includes `wpa_gui` as the default
wireless network manager. Replace "wpa\_gui" in the source code, with the name
of your icon file.

Optionally change the message associated with network restart in function
`i18n_table` and update the gettext `message.mo` template using
`usr/share/doc/fatdog-wireless-antenna/xgettext.sh`.

