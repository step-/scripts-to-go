title: DNDMATE  
date: 2019-11-07  
homepage: <https://github.com/step-/scripts-to-go>  

# Dndmate

Drag-and-drop list maker and automator

## Target User

Lists are your thing (playlist, todo list, checklist, shopping list, etc.).

Your tasks involve gathering lots of similar data items, such as, files
scattered across folders or todo notes from various projects, and so on.

## Benefits

With dndmate you can easily create a list of items incrementally.
The list is sticky: you can come back to it in a day or a year from now and you
will still find all items.  Of course, you can also clear the list, edit the
list directly from dndmate --even edit individual items in place-- keep
multiple lists, snooze individual items, rearrange items, and more.

A list is stored in a plain text file --one line one item-- you name the file.

To add an item you drag it to a drop target --one target one list.
You can change the look of the target, make it smaller, larger, change its
color and shape. You can keep multiple targets open.

And you can also add an item from the command line --no dragging required.

An item can be anything that your Linux considers "draggable". That includes a
file or folder icon, a line of text, a browser link, etc. as long as it fits on
one line. An undraggable item can still be added from the command line.

Some things that you could do with dndmate: keep your shopping list; keep a
todo list; assemble a media playlist; collect short text clips; classify your
photo file collection; keep your bookmarks, send notifications from other
applications...  Yes, you can even keep a file list.

A dndmate target can be quickly started in several ways, choose the one that
best fits your task:

* drop multiple file icons onto a dndmate desktop icon
* assign a system hotkey to start dndmate
* run dndmate from a shell command line to set specific options
* create dndmate style files
* use the included ROX-app, which has its own right-click control menu.

Advanced users can automate tasks by running shell commands on _selected_ list
items, directly from the dndmate command line.  Some examples:

> `vlc "$@"` plays the (multi-item) selection

> `cp -ar --backup "$@" ~/copies` copies all items to folder "copies"

> `ln -t ~/links -sf --backup "$@"` creates links to all items in folder "links"

(Option `--backup` creates a backup of existing files before overwriting them).

## Installing

This program can be installed from a command line shell prompt.
It should be installed to `/` for system-wide availability.

It can be started from a shell prompt.  The installer also adds a "Dndmate"
entry in section "Utility" of the system application menu.

Instructions for starting this program with a global hotkey, and as a ROX-app,
are given further down.

First, install all dependencies, see [Dependencies](#dependencies).

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, enter command
`dndmate` in a shell prompt to start the default drop target.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall this program in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

<a name="dependencies"></a>

## Dependencies

Install `yad-lib`[:2](#LINKS) >= 1.2.0.

* Since version 800, Fatdog64[:4](#LINKS) includes yad-lib 1.1.0; upgrading is
  recommended.

Install `yad`[:5](#LINKS) version 0.42. Later versions are untested with dndmate
and will probably not work well due to missing support for legacy yad features.
Also, version 0.42 is the last version to support GTK2.

* On OSes other than Fatdog64, for maximum compatibility I recommend installing
  the yad binary package[:5](#LINKS) that comes with Fatdog64-800, or compiling
  its sources.

This program requires the GNU version of `awk`, gawk >= 4.1.1, which is
commonly pre-installed on most Linux distributions.

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

<a name="basic"></a>

## Basic Usage

Start dndmate from a shell prompt or the Utility section of the system menu.

```sh
dndmate &
```

The drop target is the silver bullseye symbol on the left side of the window.
Items will appear, as you add them, in the empty box on the right side.

* Button `[R]` selects and runs commands.
* Button `[C]` copies opens a subdialog.
* Button `[Q]` exits dndmate.
* Button `[H]` shows the online help.

Hover the mouse pointer over each button to read a short description.

Now, click `[Q]` to close the target then, for some wow effect, try this command:

```sh
dndmate --optf=random.opt &
```

### Add items to the list

Open the file manager, drag one or more file icons over the bullseye, drop.
They should immediately appear as new items in **the list** view box.
You can drop files and folders, browser URLs, and lines of text.

Try from your browser. Open some website.
Drag the small lock icon located to the left of the URL in the address bar
(it is a lock for Chrome browser, it may vary for other browser), drop.
The website address should appear as a new item.

Try from your text editor, such as Geany: select some words (one line maximum),
drag and drop. A new item should appear with your words in it.
If you also see a new, empty item it means you dropped more than one line.
If can only drop one line of text at the time --excluding the newline.

You can add items from the command line. With the previous dndmate window still
open run the following shell command:

```sh
dndmate --append-exit "line before the last line" "the last line"
```

Then scroll down to the bottom of the list view. See also section
[Add items from the shell](#add_from_shell).

### List navigation

Instead of with the mouse, you can navigate through list items with the arrow
keys, `[TAB]`, etc., and press buttons with keyboard shortcuts.  The `[ALT]`
key is the shortcut prefix, and the shortcut lead is the underlined letter of
each button label. Press the prefix and the lead keys together to invoke the
shortcut.

### Search the list

Click any list item once then start typing the search term.  As you type more
letters the search advances and finds the first item that includes the term
anywhere.  Press the down arrow key to find the next matching item, and so on.
The search term is treated as a regular expression.

### Copy the list

Notice each item has a checked box. The check mark means the item is selected
for further operation. Click button `[C]` to copy the checked items.  A new
subdialog opens, which lists all checked items as text.  Select some text and
copy it to the clipboard with a right-click.  Click `[OK]` to close the
subdialog.

> Keyboard shortcut: select and item with the arrow keys, press the Space bar
> to toggle the check mark on and off.

### Edit individual list items

Click an item in the main window to select it.
Then click it again to edit its content.
Right click it to delete or duplicate it.
Right click also to add a new, empty item at the end of the list.
Then click it to select it and click again to edit its content.

> Keyboard shortcut: with and item selected press the right arrow key once to
> turn edit mode on.  To exit edit mode press the Enter key.

### Edit the list as a whole

In the main window click button `[C]`. Notice the `[Edit]` button. Click it.
Your text editor opens the **raw file** that backs all items.
You can edit this file to add, modify delete items but follow the line format.

If an item is to be checked in the main window its line begins with `TRUE|`.
It the item is not to be checked its line begins with `FALSE|`.
Then follows the item text, and finally two vertical bars `||` to end the item.
Each line must contain exactly three vertical bars in the indicated positions.
Therefore, no item can contain a vertical bar --but see the
[next section](#reserved-character) for ways to get around this.

Save the file (or don't to discard your changes). Close your text editor.
Click `[OK]` in the subdialog.

> _Note: the file is referred to as the **raw file**. There is also another
> file, referred to as the **ref file**, which lists the contents of checked
> items only --equivalent to the content of the copy subdialog.

<a name="reserved-character">

### Reserved character

As we have seen, by default dndmate reserves the vertical bar character `|`,
therefore no item is allowed to contain that character. However, you can change
the reserved character, to allow items to include `|`, by setting environment
variable [DNDMATE\_SEPARATOR](#envvars) to some other character, which no item
will include. See also the _Reserved character_ topic accessible by clicking
button `[H]` in the main window.

### Clear the list

When you clear the list _all items are lost_ --they cannot be recoved.
To clear the list click `[C]` in the main window, then click `[Clear]`.
You will be prompted to confirm your intention.

### Save and back up the list

By default the list and raw files are saved automatically into the system
temporary directory.  Therefore, they will be deleted when the system reboots.
However, they can be made permanent by setting environment variable
[_DNDMATE\_REFS](#envvars).

There is no "Backup" command per se because backing up simply amounts to
copying the **raw file** to a destination of your liking. For that you need
to know where the raw file is located. You can find out in two ways:

* Open the raw file in your text editor, as explained above.
* Click button `[H]` in the main window, scroll down after topic _Option_
  to topic _The "Ref" File - DNDMATE_REFS and REFs_ and read how then
  names of the raw and list files are formed, and can be customized.

### Export the list

There is no "Export" command per se because exporting simply amounts to
copying the **list file** to a destination of your liking. For that you need
to know where the list file is located. You can find out in two ways:

* Hover the mouse pointer over button `[H]` and read the tooltip.
* Edit the list file to open it.
* Do as explained about button `[H]` in section _Backing up the list_.

### Name your lists! (ID)

Do you want to create more than one list? Then you must read this.

Name each new list by giving it an ID, e.g., `dndmate --id=this-ID`.
A given ID brings its own distinct "Ref" file and window group.
All dndmate windows belong to some group.

With `--id` dndmate can distinguish all (sub)windows that share the same ID,
and apply options and actions to members of that ID group only.
Without `--id` REFs and windows belong to the single, unnamed, default group.
If `--id` is not followed by `=ID`, a new, unique, unnamed group is formed.
If `--id=ID` is given the window title displays the name `ID`, and new REFs
are added under that ID.

if you want to run multiple drop targets --either together or one by one--
you need to understand about the target ID, which is simply a text string
you choose to identify each target, therefore its raw data file.

To run a dndmate target with a given ID, say "MyTarget", start dndmate this way:

```sh
dndmate --id="MyTarget"
```

This automatically adds "myTarget" to the name of the **raw file**.
Remember to specify `--id="MyTarget"` every time you want to access that
particular list.

> Click button `[H]` and read section _Understanding IDs_ to know
> ŵhat other things can be affected by giving a target an ID.

> When running multiple targets at the same time, they all must be given
> different IDs. This is because if two targets share the same ID, the second
> one to start will _replace_ the first one.  This is so even if the two
> targets _look_ different to you. The look does not matter. The ID does.

### Run shell commands on list items

With some items checked in the main window, click button `[R]`.
This will open a one-line entry form where you can enter a shell command or
selected a previous command from the pull-down menu.

Your command can be anything, it does not need to refer to the checked item,
but normally it will.  The placeholder for the checked items is entered as
`"$@"`. This syntax is just the regular shell syntax, if you understand
shell prompt usage.

> Caveat: by default the output of your command isn't redirected at all,
> therefore it goes to dndmate's standard ouput. If you started dndmate from a
> terminal you will see your command's output there. If instead you started
> dndmante from an icon you will not see command output, unless your command
> explicitly redirects its standard output.

Executed commands are saved to the history log file.
By default this file is saved automatically into the system temporary
directory.  Therefore, it will be deleted when the system reboots.
However, you can be made permanent by setting environment variable
[_DNDMATE\_HISTORY](#envvars).

### ROX-app (optional)

If ROX-Filer is your file manager, you can drag the ROX-app icon
`/usr/local/apps/dndmate` to your desktop. The icon responds to drop icons.
You can also right-click the icon and select the "dndmate" item to access a
specific submenu.

To change the icon color:

```sh
cd /usr/local/apps/dndmate
# change p to one of the available colors; to list colors: ls res
p=red
ln -sf res/dndmate_$p.svg .DirIcon
```

### Assigning a global hotkey (optional)

The following instructions apply to sven[:3](#LINKS) --- the multimedia
keyboard manager in Fatdog64 Linux[:4](#LINKS).
They assume that key Windows+b isn't already assigned as a hotkey.
If it is assigned, you need to disable the assignment in sven's configuration
before re-assigning it.

* Right-click the keyboard icon -- located in the desktop panel icon tray --to
  open sven's menu, and select Preferences
* Click Keyboard > New > Description and type _Drag-and-drop list maker Win+b_
* Click inside input field Key Code with your mouse, then press keys "Windows"
  and "b" together, don't press other keys
* Click inside input field Text Display with your mouse, then type "System and
  Applications"
* Click the Program radio button, and type:
  `dndmate --id --optf=random.opt`.
  The command set a unique group id, and merges more options from preset file
  `random.opt` --located in the ROX-app folder. In turn `random.opt` sets the
  compact window style, and a random target symbol in the range 20-44 of the
  global style file `/usr/share/dndmate/stylef`.
* Click OK and close sven.
* Alternatively, you could set the Program field with another preset:
  * `dndmate --optf=random-lowercase-id.opt`
  * `dndmate --optf=random-uppercase-id.opt`

Press Win+b to test the global hotkey.

<a name="advanced_usage"></a>

## Advanced Usage

<a name="envvars"></a>

### Configuration through environment variables

**TL;DR** --
To make the list file and the history file permanent (survive a system reboot)
add the following lines to your user profile file
(`~/.fatdog/profile` in Fatdog64),
log out and log in again:

```sh
export DNDMATE_HISTORY="$HOME/.cache/dndmate-history.sh"
export DNDMATE_REFS="$HOME/.cache/dndmate-refs-%s.txt"
```

---

Dndmate does not provide a user configuration file to set preferences. Instead
it expects preferences to be set in the form of environment variables, which a
user can either set when invoking a single dndmate instance, or set in the user
profile file to affect all future invocations.
(Changes to the user profile file are effective at the next login).

Run `dndmate --help=all` or click button `[H]` in the main window to read more
about the following environment variables:

> `DNDMATE_EDITOR` -- history editor program path,
> default `defaulttexteditor` or `geany` or `leafpad`

> `DNDMATE_HISTORY` -- history file path template,
> default `/tmp/$USER-dndmate-history%s.sh`

> `DNDMATE_REFS` -- list file path template,
> default `/tmp/$USER-dndmate-refs%s.txt`

> `DNDMATE_SEPARATOR` -- reserved character that items must not include,
> default `|`

> `DNDMATE_STYLEF` -- style file path,
> default `/usr/share/dndmate/stylef`

> `DNDMATE_YAD_INITIAL_POSITION` -- initial window placement and size,
> e.g., `--center --width=500`

> `DNDMATE_YAD_OPTIONS` -- extra yad options,
> e.g., `--on-top`

> `SHELL` -- user command processor

### Style file

Dndmate targets can be styled, essentially to change the window layout and
icon, and the drop target symbol and color; see option `--stylef` in the
runtime help (`[H]`).  New styles can be saved to a personal style file or
added to the global style file `/usr/share/dndmate/stylef`; see that file for
instructions.

<a name="add_from_shell">

### Add items from the shell

One thing is to add items _and_ close (exit) dndmate.  Another thing is to add
items and keep dndmate open with the expectation to add more items later.  Both
scenarios can be easily achieved but how to do the latter isn't immediately
obvious.

**First scenario:** add and close

1. Make sure that dndmate isn't already running, then
2. Run `dndmate [--id=ID] [--append] item1 item2 ...` then
3. Close dndmate.

Repeat steps 2 and 3 as long as necessary. Square brackets wrap optional
elements. Adding `--id=ID` serves to name a specific list (and its windows).
Adding `--append` serves to emphasize that we are adding items, and it's
pedantic because appending is dndmate's default action anyway.

Step 1 above is essential. If you were to append in step 2 while another
dndmate (identified by the same ID) was still running, the list would be
doubled in size --probably not what you expected.

**Second scenario:** add while another dndmate is running

1.  Run `dndmate [--id=ID] --append-exit item1 item2 ...`

With `--append-exit` no window is started, so the existing dndmate window
keeps running and will show the new items. If no window is running this
will be a silent update; you won't notice until you start a new window.

Another way to add when another dndmate is running:

1. Close the running dndmate with `dndmate [--id=ID] --close --exit`
2. Start a new window `dndmate [--id=ID] item1 item2 ...`

Nothing bad would happen if no dndmate was running in step 1 above.

## Esoteric Usage

External applications can call the dndmate style engine to generate a random
SVG icon for their own use, e.g.:

```sh
TMPS=/tmp/myApp.$$.tmp
rm -f "$TMPS" # --icon-get appends
if dndmate --stylef=: "$@" --icon-get="$TMPS" --clean --exit; then
  read DND_SVG_ICON < "$TMPS"
fi
# The new icon file path is $DND_SVG_ICON.
```

<a name="tips"></a>

## Tips

* To work on different lists at once, run separate instances with `--id`, i.e.

```sh
dndmate --id=music & dndmate --id=weblinks &
```

* The above example rewritten to take advantage of the two predefined styles
  "MyMusic" and "-MyMusic":

```sh
dndmate --stylef=:MyMusic & dndmate --stylef=:-MyMusic &
```

* Preload your frequently-used commands into the command history file.
  Click `[R]` in the main window then click `[Edit]`.

* The runtime help page starts with a TL;DR section!

## Help

While dndmate is active hover over the GUI buttons for tooltip help or
press the Help button for full help, which is also accessed with

    dndmate --help=all

This file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man dndmate

## AUTHOR

step

Thanks to stemsee and MochiMoppel for early discussion.

<a name="LINKS">

## LINKS

**Homepage**
[github.com/step-/scripts-to-go](https://github.com/step-/scripts-to-go)

**:1** release page
[github.com/step-/scripts-to-go/releases](https://github.com/step-/scripts-to-go/releases)

**:2** yad-lib
[github.com/step-/yad-lib](https://github.com/step-/yad-lib)

**:3** sven multimedia keyboard manager

* source
[distro.ibiblio.org/fatdog/source/800/sven-20190207.tar.bz2](http://distro.ibiblio.org/fatdog/source/800/sven-20190207.tar.bz2)

* 64-bit binary
[distro.ibiblio.org/fatdog/packages/800/sven-2019.02-x86_64-1.txz](http://distro.ibiblio.org/fatdog/packages/800/sven-2019.02-x86_64-1.txz)

**:4** Fatdog64 Linux
[distro.ibiblio.org/fatdog/web/](http://distro.ibiblio.org/fatdog/web/)

**:5** yad - a GTK dialog program
[github.com/v1cont/yad](https://github.com/v1cont/yad/)

* Fatdog64 800 binary package
[distro.ibiblio.org/fatdog/packages/800/yad_gtk2-0.42.0_5](http://distro.ibiblio.org/fatdog/packages/800/yad_gtk2-0.42.0_5-x86_64-1.txz)

* Fatdog64 800 source (the build recipe can be found under `/usr/src` in the binary package)
[distro.ibiblio.org/fatdog/source/800/yad_gtk2-62d54eb5bf5ae2457c6986c33c6de89a6284f969.tar.gz](http://distro.ibiblio.org/fatdog/source/800/yad_gtk2-62d54eb5bf5ae2457c6986c33c6de89a6284f969.tar.gz)

* Puppy Linux forum - yad tips thread
[murga-linux.com/puppy/viewtopic.php?p=908353#908353](http://murga-linux.com/puppy/viewtopic.php?p=908353#908353)

