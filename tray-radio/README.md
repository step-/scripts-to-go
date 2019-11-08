title: TRAY-RADIO  
date: 2019-09-17  
homepage: <https://github.com/step-/scripts-to-go>  

# tray-radio

Internet radio and media file tray icon menu

## Target User

You want to select Internet radio stations and other media, from a menu using
your existing `.m3u` playlists and/or URL lists.

You maintain your playlists as text files without extra frills.

You want a light-weight, quick, simple solution without flashy graphics.

## Installing

This script can be installed and started from a command line shell prompt.
No iconic shortcut or application menu is available.

First, install all dependencies --- see section _Dependencies_.

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, you should be able to
run `/usr/bin/tray-radio --tray &` to start the tray icon.

**Important** --- After having completed the installation you **must** save file `install.log`, which is located in folder `install/`, if you want to be able to
uninstall this program in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

## Dependencies

Install `gtkmenuplus`[:2](#LINKS).

Optionally install the `mpg123`[:3](#LINKS) command-line MP3 player (recommended).
Details vary by OS distribution.
Fatdog64 800 already includes mpg123 in the base OS.
For Fatdog64 7xx, install the package[:4](#LINKS) using the gslapt package manager.

Running `tray-radio --help=all` will list other dependencies near the end of
the output text.

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

## Help

Run one of the following lines:

    tray-radio --help
    tray-radio --help=all
    tray-radio --help=all-gui

## FILES

/usr/share/tray-icon/ --- Default playlist folder

## FAQ

1. Can tray-radio use my preferred media player 'xyz'?

Yes. It can even use different media players in the same menu. See help topic
_DEFAULT PLAY COMMAND_.

2. Can I format menu items with color, different fonts, etc.?

Yes. You can apply all `gtkmenuplus` formatting directives[:2](#LINKS).
See help topic _GTKMENUPLUS-ENTRY_.

3. Can I add icons to the menu?

Yes. Use `#menu icon=`. An example is shown when you run `tray-radio --help=all`.

4. Does tray-radio support theming?

Yes. It supports GTK2 menu themes, so you can change the way the menu looks,
and the icon set associated with the theme. See help topic _THEMING_.

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

* formatting directives
  [blob/master/docs/menu\_configuration\_file\_format.md](https://github.com/step-/gtkmenuplus/blob/master/docs/menu_configuration_file_format.md)

**:3** mpg123
[mpg123.de](https://mpg123.de)

**:4** Fatdog64 7xx `mpg123` package
[distro.ibiblio.org/fatdog/contrib/packages/710/mpg123-1.23.8-x86\_64-1.txz](http://distro.ibiblio.org/fatdog/contrib/packages/710/mpg123-1.23.8-x86_64-1.txz)

