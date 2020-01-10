title: QUICKLAUNCH  
date: 2020-01-10  
homepage: <https://github.com/step-/scripts-to-go>  

# quicklaunch

Quick-launch user menu

## Target User

You are confortable editing a single configuration file with a text editor.

You want to organize your recently-used applications and documents into a
quick-launch menu, and invoke it with a global hotkey.

## Installing

This script can be installed and started from a command line shell prompt.
No desktop shortcut or application menu entry is installed, but you will be
able to invoke the menu from the LXQt desktop panel, and from a global hotkey.

The installer will add several files to your home folder, as well as some GTK2
themes. The latter should be installed to `/` for system-wide availability.

First, install all dependencies, see [Dependencies](#dependencies).

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, you should be able to
enter command `~/quicklaunch.gtkmenuplus` in a shell prompt to display the
default quick-launch menu.  If it is displayed then you can proceed  to read
section [Configuration](#configuration) to learn how to assign the menu a
global hotkey, and how to invoke the menu from LXQt panel.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall quicklaunch in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

<a name="dependencies"></a>

## Dependencies

Install `gtkmenuplus`[:2](#LINKS).

* Since version 800, Fatdog64 includes gtkmenuplus; no need to install it again.

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

<a name="configuration"></a>

## Configuration

### Assigning a global hotkey (optional)

The following instructions apply to sven[:3](#LINKS) --- the multimedia
keyboard manager in Fatdog64 Linux[:4](#LINKS).
They assume that key Windows+X isn't already assigned as a hotkey.
If it is assigned, you need to disable the assignment in sven's configuration
before re-assigning it.

* Right-click the keyboard icon -- located in the desktop panel icon tray --to
  open sven's menu, and select Preferences
* Click Keyboard > New > Description and type _Quicklaunch Menu Win+x_
* Click inside input field Key Code with your mouse, then press keys "Windows"
  and "X" together, don't press other keys
* Click inside input field Text Display with your mouse, then type "My
  quicklaunch menu"
* Click the Program radio button, and type: `/root/quicklaunch.gtkmenuplus`
  (Change path `/root` to your home path, into which you installed quicklaunch)
* Click OK and close sven.

Press Win+x to test the global hotkey.

### Invoking quicklaunch from the desktop panel (optional)

The following instructions apply to LXQt panel --- the Fatdog64
Linux[:4](#LINKS) desktop panel.

Let's start by adding your quicklaunch menu as a quick-launch panel icon.

* Edit file `~/.config/lxqt/panel.conf`.  If this file does not exist,
  copy the system default file `/etc/xdg/lxqt/panel.conf` to
  `~/.config/lxqt/panel.conf` then edit the copy.  Find section
  `[quicklaunch]`.  It should look something like the following text block:

```
[quicklaunch]
alignment=Left
apps\1\desktop=/usr/share/applications/default-browser.desktop
apps\2\desktop=/usr/share/applications/urxvt.desktop
apps\3\desktop=/usr/share/applications/rox.desktop
apps\4\desktop=/usr/share/applications/fatdog-control-panel.desktop
apps/size=4
type=quicklaunch
```

* Change `apps/size=4` to `apps/size=5`
* then insert a new line above `apps/size=5` and type:
  (replace path `/root` with your home path, in which you installed quicklaunch):

```
apps\5\desktop=/root/.local/share/applications/quicklaunch.desktop
```

Save the file and restart LXQt panel or X Windows for the changes to take
effect.  Notice the new panel icon near the Control Panel icon.  Click it to
display your quicklaunch menu.  The first four menu items should duplicate the
first four panel icons.  This is so because, by default, your quicklaunch menu
imitates the default LXQt panel `[quicklaunch]` configuration section.

Duplication can be confusing.
You can condense all LXQt panel quick-launch icons into a single menu icon.
Simply change the text block to:

```
[quicklaunch]
alignment=Left
apps\1\desktop=/root/.local/share/applications/quicklaunch.desktop
apps\size=1
type=quicklaunch
```

Save the file and restart LXQt panel or X Windows for the changes to take
effect.  Now only the quicklaunch icon takes up valuable panel space.

### Setting a theme (optional)

If you did add the quicklaunch icon to the Desktop Panel, you may also want
for the menu colors to match the Desktop Panel theme. By default, your
quicklaunch menu uses the Onyx theme.  To apply a different theme
edit file `~/.local/share/applications/quicklaunch.desktop`,
and read further instructions there.

## Customizing the menu

Your menu is implemented as a gtkmenuplus[:2](#LINKS) script file.  Adding a
new menu item is relatively straightforward: specify a label for the item, the
command it should execute, the path of an icon file. The following example adds
two new items:

```gtkmenuplus
Item = _1 yad says hello world
Cmd = yad --center --text="hello world"
Icon = yad

Item = _2 xdialog says hello world
Cmd = Xdialog --screen-center --msgbox "hello world" 0x0
Icon = gtk-dialog-info
```

Add the above text block to file `~/quicklaunch-user.gtkmenuplus`.
Then invoke the menu by clicking its icon in the desktop panel, or typing the
quicklaunch menu global hotkey, or running `~/quicklaunch.gtkmenuplus` in a
shell prompt.  Either way, the menu will show the two new items. If it does
not, you did something wrong. Then try running `~/quicklaunch.gtkmenuplus` in a
shell prompt and see what error messages it prints --- if they help you
understand what you possibly did wrong.

Explaining the full format of a gtkmenuplus configuration file is beyond the
scope of this document. Read the "formatting directives"[:2](#LINKS) manual to
learn all that.  You can also imitate one of several items that are supplied
in the sample user file, `~/quicklaunch-user.sample`, and in the main menu
file, `~/quicklaunch.gtkmenuplus`.

Recommendation: abstain from modifying the main menu file, directly because if
you make a mistake your menu could not be displayed at all.  Instead, put all
your changes in the user file.  Another reason for not changing the main file
directly is that your changes would be overwritten upon updating this package.
On the other hand, the user file never gets overwritten.

# Preferred programs and the user-var file

Some quicklaunch items invoke the default browser and the default text editor.
You can change the default programs just for quicklaunch by editing the
_user-var_ file, `quicklaunch-user-var.gtkmenuplus`: uncomment the settings,
and replacing the sample values:

```
# defaultbrowser=firefox
# defaulttexteditor=geany
```

The other lines of the user-var file affect advanced features.

## Advanced features

### Recent submenu

Since version 1.1.0, the quicklaunch menu tracks all item invocations, and adds
them to the Recent sub-menu, and to a "recent list" displayed at the bottom of
the menu.

Tracked items are saved in a file named by gtkmenuplus variable
`RECENTFILE`, which expands to file path `~/.gmenu2.log`.  This path is
shared with gmenu2[:5](#LINKS) --- a System and Application menu in the
Scripts-To-Go collection.  `RECENTFILE` can be set in the user-var file.

The number of items shown in the recent list can be configured by uncommenting
and changing the value of gtkmenuplus variable `SHOW_LAST_N_COMMANDS` in file
user-var.  Its default value is `1`, which means that only the last invoked
command is shown.

To exclude a specific item from being tracked --- hence from being added to the
recent list -- you need to add the special string `@prune_this@` to the item's
`Cmd` value. For instance, the following item is tracked:

```gtkmenuplus
Item = test command
Cmd = yad --center --text="hello world"
Icon = yad
```

but if you rewrite it as:

```gtkmenuplus
Item = test command
Cmd = sh -c ": @prune_this@; yad --center --text=\"hello world\""
```

it stops being tracked, while producing the same practical effect as before
(launching yad).  "Pruning" is the technical term we use for clearing the
recent list from items that have been marked with `@prune_this@`.
Usually, pruning takes place automatically, but there could be situations in
which you will need to prune manually; there is a menu entry in the Tools
section for doing that.

The string `@prune_this@` can be changed and extended. In fact, it already
comprises the following values: "Reboot", "Restart X", "Shutdown" and
"Suspend", which excludes those menu labels from tracking.  The combined
"do-not-track" string is a regular expression, which can be specified in file
user-var as variable `PRUNEREX`. Its default value is

```sh
PRUNEREX="@prune_this@|Item=(Reboot|Restart X|Shutdown|Suspend)"
```

Occasionally you may wish you could edit the Recent submenu directly. That is
possible but its menu entry is hidden by default. To enable this feature type
to the shell:
```
~/quicklaunch-user.gtkmenuplus 0 1
```
then select menu entry "Tools > Edit Recent Menu".  The file format is a bit
obscure but essentially each menu entry ends on a line like this `#{}`.

### ROX Bookmarks submenu

This is what the title says: your ROX-Filer bookmarks are integrated as a
submenu of the quicklaunch menu.
To edit your bookmarks go to ROX-Filer.

For easy integration of ROX-Filer bookmarks a stand-alone version of the ROX
bookmarks submenu is installed in your home folder with the name
`rox-bookmarks.gtkmenuplus`.

### Tools submenu

This submenu provides entries to
- edit the main menu configuration file (for expert users)
- edit the user menu configuration file (your entries)
- edit the Recent submenu (hidden by default)
- prune the Recent submenu and recent list
- sort the Recent submenu by different criteria.

## Help

This file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man quicklaunch

and for help about gtkmenuplus directives you will run command:

    man 5 gtkmenuplus

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

**:5** Gmenu2 Fatdog64 system and application menu
[github.com/step-/gtkmenuplus](https://github.com/step-/scripts-to-go/#gmenu2)
