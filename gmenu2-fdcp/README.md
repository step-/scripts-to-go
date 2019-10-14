title: GMENU2-FDCP  
date: 2019-10-13  
homepage: <https://github.com/step-/scripts-to-go>  

# gmenu2-fdcp

Stand-alone Fatdog64 control menu (also gmenu2 extension)

## Intended Use

As a stand-alone menu equivalent to the Fatdog64 control panel for
Fatdog64 700-721 users.

As a gmenu2[:6](#LINKS) extension.

## Installing

* Fatdog64 800 already provides a very similar Control Menu.
* As a gmenu2 extension this script is only needed for Fatdog64 `<=` 802.

This script can be installed from a command line shell prompt.
It should be installed to `/` for system-wide availability.

It can be started from a shell prompt.  The installer also adds a "Fatdog64
Control Menu (gmenu2-fdcp)" entry in section "Setup" of the system application menu.

First, install all dependencies, see [Dependencies](#dependencies).

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, enter command
`gmenu2-fdcp` in a shell prompt to display the control menu.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall gmenu2-fdcp in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

<a name="dependencies"></a>

## Dependencies

Install `gtkmenuplus`[:2](#LINKS).

* Since version 800, Fatdog64 includes gtkmenuplus; no need to install it again.

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

## Configuration

### Assigning a global hotkey (optional)

The following instructions apply to sven[:3](#LINKS) --- the multimedia
keyboard manager in Fatdog64 Linux[:4](#LINKS).
They assume that key Windows+m isn't already assigned as a hotkey.
If it is assigned, you need to disable the assignment in sven's configuration
before re-assigning it.

* Right-click the keyboard icon -- located in the desktop panel icon tray --to
  open sven's menu, and select Preferences
* Click Keyboard > New > Description and type _Stand-alone Control Menu Win+m_
* Click inside input field Key Code with your mouse, then press keys "Windows"
  and "m" together, don't press other keys
* Click inside input field Text Display with your mouse, then type "System and
* Applications"
* Click the Program radio button, and type: `gmenu2-fdcp`
* Click OK and close sven.

Press Win+m to test the global hotkey.

### Setting a theme (optional)

If `quicklaunch`[:5](#LINKS) is installed, you can theme the gmenu2 menu using
the themes and instructions provided with the quicklaunch package.

## Help

For a short usage summary run the following line:

    gmenu-fdcp --help

This file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man gmenu2-fdcp

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

* formatting directives ( `man 5 gtkmenuplus` )
  [blob/master/docs/menu\_configuration\_file\_format.md](https://github.com/step-/gtkmenuplus/blob/master/docs/menu_configuration_file_format.md)

**:3** sven multimedia keyboard manager

* source
[distro.ibiblio.org/fatdog/source/800/sven-20190207.tar.bz2](http://distro.ibiblio.org/fatdog/source/800/sven-20190207.tar.bz2)

* 64-bit binary
[distro.ibiblio.org/fatdog/packages/800/sven-2019.02-x86_64-1.txz](http://distro.ibiblio.org/fatdog/packages/800/sven-2019.02-x86_64-1.txz)

**:4** Fatdog64 Linux
[distro.ibiblio.org/fatdog/web/](http://distro.ibiblio.org/fatdog/web/)

**:5** Quicklaunch user menu
[github.com/step-/gtkmenuplus](https://github.com/step-/scripts-to-go/#quicklaunch)

**:6** Gmenu2: Stand-alone extended application menu
[github.com/step-/gtkmenuplus](https://github.com/step-/scripts-to-go/#gmenu2)
