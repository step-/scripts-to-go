title: FATDOG-WIRELESS-ANTENNA  
date: 2019-10-17  
homepage: <https://github.com/step-/scripts-to-go>  

# fatdog-wireless-antenna

WiFi antenna manager for Fatdog64

## Target User

* Fatdog64 users operating a PC with multiple wireless interfaces.
* Other (Puppy) Linux users -- minimum shell source code adaptions needed, see
  [Porting to Other Linux](#porting).

## Installing

* Since version 720 Fatdog64[:4](#LINKS) includes this script and its dependencies.
  In comparison to that version, this version adds better packaging: this
  README file, a Linux manual page, and an interactive installer/uninstaller.

This script can be installed from a command line shell prompt.
It should be installed to `/` for system-wide availability.

It can be started from a shell prompt.  The installer also adds a "WiFi
Antenna Manager" entry in section "Utility" of the system application menu.

First, install all dependencies, see [Dependencies](#dependencies).

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, enter command
`fatdog-wireless-antenna.sh &` in a shell prompt to start the antenna manager.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall gmenu2-fdcp in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

<a name="dependencies"></a>

## Dependencies

Install `shnetlib`[:2](#LINKS) and `yad-lib`[:3](#LINKS).

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

## Help

Hover over GUI list items for tooltip help.

This file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man fatdog-wireless-antenna

<a name="porting"></a>

## Porting to Other Linux

See file PORTING[:5](#:LINKS)

## AUTHOR

step and the Fatdog64 team.

<a name="LINKS">

## LINKS

**Homepage**
[github.com/step-/scripts-to-go](https://github.com/step-/scripts-to-go)

**:1** release page
[github.com/step-/scripts-to-go/releases](https://github.com/step-/scripts-to-go/releases)

**:2** shnetlib
[github.com/step-/shnetlib](https://github.com/step-/shnetlib)

**:3** yad-lib
[github.com/step-/yad-lib](https://github.com/step-/yad-lib)

**:4** Fatdog64 Linux
[distro.ibiblio.org/fatdog/web/](http://distro.ibiblio.org/fatdog/web/)

**:5** PORTING - Porting to Other Linux
[github.com/step-/scripts-to-go/blob/fatdog-wireless-antenna/usr/share/doc/fatdog-wireless-antenna/PORTING.md](https://github.com/step-/scripts-to-go/blob/fatdog-wireless-antenna-1.0.0/fatdog-wireless-antenna/usr/share/doc/fatdog-wireless-antenna/PORTING.md)

