title: GMENU2  
date: 2024-02-02  
homepage: <https://github.com/step-/scripts-to-go>  

# gmenu2

Alternative desktop menu implementation using gtkmenuplus

## Compatibility

Gmenu2 loosely follows the specification for XDG menu applications.
It is developed for Fatdog64 Linux, and it could be lacking for other
distributions.

## Target User

You remaster Fatdog64 and want a stand-alone application menu that works
without a window manager or a desktop panel.

## Installing

This script can be installed from a command line shell prompt.
It should be installed to `/` for system-wide availability.

It can be started from a shell prompt.  The installer also adds a "Gmenu2"
entry in section "Desktop" of the system application menu.

First, install all dependencies, see [Dependencies](#dependencies).
Then, optionally install extensions, see [Extensions](#extensions).

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, enter command
`gmenu2` in a shell prompt to display the gmenu2 menu.
Probably several non-fatal error messages will be printed to the terminal
but as long as the menu is displayed all is good.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall gmenu2 in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

<a name="dependencies"></a>

## Dependencies

Install `gtkmenuplus`[:2](#LINKS).

* Since version 800, Fatdog64 includes gtkmenuplus; no need to install it again.

<name a="extensions"></a>

## Extensions

If `quicklaunch` is installed, it can share recently selected menu entries with
gmenu2.

* Optional: install `quicklaunch`[:5](#LINKS).
  See also section [Configuration](#configuration).

If `gmenu2-fdcp` is installed, gmenu2 will display menu entries for the
Fatdog64 Control Panel. This extension is only needed for Fatdog64 <= 802.

* Optional: install `gmenu2-fdcp`[:6](#LINKS).

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

The uninstaller will not remove the user's configuration files:
`~/.gmenu2rc` and `~/.gmenu2.log`.

## Submenus

In addition to providing the system application menu, gmenu2 provides some
submenus of its own:

> Control panel

See [Extensions](#extensions).

> Recent

> Tools

> Uncategorized

See [Configuration](#configuration).

> Wine

If the Wine emulator is installed, and it is configured to add Wine
applications to the system menu, this submenu will show such applications.

<a name="configuration"></a>

## Configuration

### Preferences file

Gmenu2 self-configures on the first run; you do not need to do anything.
You can change some menu preferences directly from
the gmenu2 menu, and also by editing file `~/.gmenu2rc`, which gmenu2 creates
if the file does not exist.  Default preferences:

> `IGNORENODISPLAY="0"`

If this setting is enabled ("1") gmenu2 will not hide the application menu
entries that the default system application menu always hides.
You can toggle this setting by selecting "Gmenu2 > Show concealed applications"
in gmenu2.

> `INLINE="1"`

If this setting is disabled ("0") gmenu2 will not group applications by
categories but instead the menu will be a very long, flat list of entries. This
is probably not what you want.  This setting is not exposed in the menu. If you
experiment and change it, and then set it back, you will also need to remove
the menu cache directory, `/tmp/gmenu_$USER`, where `$USER` is your login name.

> `REFRESH_CACHE="0"`

If this setting is enabled ("1") gmenu2 will rebuild the menu cache each time
it is invoked. Building the cache delays showing the menu.
It this setting is disabled ("0") gmenu2 will build the cache automatically
only if it does not already exist.  This displays the menu faster (after the
first menu invocation) but gmenu2 will not display entries for newly installed
applications unless you tell it to update the cache.

You can force cache updates by selecting "Gmenu2 > Refresh cache" in gmenu2.
Forced updates will keep going until disabled with
"Gmenu2 > Stop refreshing the cache".

> `SUBMENU_UNCATEGORIZED_APPS="0"`

Application packagers may choose not to assign an application to any known
application category. In this case the application is not listed in the default
system application menu. By enabling this setting ("1") such uncategorized
applications will be listed in the "Uncategorized" submenu.

> `SUBMENU_ACTIVATIONS="1"`

If this setting is enabled ("1"), all menu entry activations will be logged
to the file specified by user preference `LOGFILE_ACTIVATIONS`, and shown
in the "Recent" submenu.

If `quicklaunch`[:5] is installed it will share its own Recent submenu items
with gmenu2 via the log file. This way whatever entry is activated in one menu
will also be seen in the other menu's Recent submenu.

> `LOGFILE_ACTIVATIONS="/root/.gmenu2.log"`

This file logs all activations (if enabled) in a format suitable for sharing
with `quicklaunch`[:5].

> `MNEMONIC="1"`

If this setting is disabled ("0") gmenu2 will not add keyboard accelerators of
its own.  The keyboard key that corresponds to a label's underlined character,
if one exists, can be pressed to jump to that label, which is therefore said
"accelerated".  If `MNEMONIC` is `"1"` gmenu2 will set the first character of
each "unaccelerated" label as its accelerator.

> `ICONSIZE="24"`

The size of menu item icons in pixels.

### Assigning a global hotkey (optional)

The following instructions apply to sven[:3](#LINKS) --- the multimedia
keyboard manager in Fatdog64 Linux[:4](#LINKS).
They assume that key Windows+s isn't already assigned as a hotkey.
If it is assigned, you need to disable the assignment in sven's configuration
before re-assigning it.

* Right-click the keyboard icon -- located in the desktop panel icon tray --to
  open sven's menu, and select Preferences
* Click Keyboard > New > Description and type _Stand-alone System Menu Win+s_
* Click inside input field Key Code with your mouse, then press keys "Windows"
  and "s" together, don't press other keys
* Click inside input field Text Display with your mouse, then type "System and
  Applications"
* Click the Program radio button, and type: `gmenu2`
* Click OK and close sven.

Press Win+s to test the global hotkey.

### Setting a theme (optional)

If `quicklaunch`[:5](#LINKS) is installed, you can theme the gmenu2 menu using
the themes and instructions provided with the quicklaunch package.

## Help

This file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man gmenu2

Tip: by default the menu contents are cached. To troubleshoot any issues start
by removing the menu cache directory, `/tmp/gmenu_$USER`, where `$USER` is your
login name.

## AUTHOR

step

<a name="LINKS">

## LINKS

**Homepage**
<https://github.com/step-/scripts-to-go#gmenu2>

**:1** release page
<https://github.com/step-/scripts-to-go/releases>

**:2** gtkmenuplus
<https://github.com/step-/gtkmenuplus>

* formatting directives ( `man 5 gtkmenuplus` )
  <https://github.com/step-/gtkmenuplus/blob/master/docs/menu_configuration_file_format.md>

**:3** sven multimedia keyboard manager

* source
<http://distro.ibiblio.org/fatdog/source/900/sven-2023.07.02.tar.bz2>

* 64-bit binary
<http://distro.ibiblio.org/fatdog/packages/900/sven-2023.07-x86_64-1.txz>

**:4** Fatdog64 Linux
<http://distro.ibiblio.org/fatdog/web/>

**:5** Quicklaunch user menu
<https://github.com/step-/scripts-to-go/#quicklaunch>

**:6** Gmenu2 extension: Fatdog64 Control Panel
<https://github.com/step-/scripts-to-go/#gmenu2-fdcp>
