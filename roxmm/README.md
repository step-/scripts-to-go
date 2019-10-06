title: ROXMM  
date: 2019-10-05
homepage: <https://github.com/step-/scripts-to-go>  

# roxmm

ROX-Filer SendTo menu emulator

## Target User

Script developers who need to emulate the rox SendTo menu in their
applications.

ROX-Filer power users and tweakers.

## Installing

This script can be installed and started from a command line shell prompt.
No desktop shortcut or application menu entry is available.
You must install to `/` to enable ROX-Filer integration.
The installer will also add several files to your home folder.

First, install all dependencies --- see section _Dependencies_.

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, you should be able to
run `/usr/bin/roxmm /path/to/file` to start a right-click menu for `file`
(replace `/path/to/menu` with the real path of an existing file).

Also, a new entry, "Roxmm Item Menu", should now appear in the rox right-click
SendTo menu of files and folders. This entry is installed to make comparison of
the emulated menu with the actual rox SentTo menu easier.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall this program in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

## Dependencies

Install `gtkmenuplus`[:2](#LINKS).

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

## Help

Run the following line:

    roxmm --help

## AUTHOR

step

<a name="LINKS">

## LINKS

**Homepage**
[github.com/step-/scripts-to-go](https://github.com/step-/scripts-to-go)

**:1** release page
[github.com/step-/scripts-to-go/releases](https://github.com/step-/scripts-to-go/releases)

**:2** gtkmenuplus
[github.com/step-/gtkmenuplus](https://github.com/step-/gtkmenuplus)
