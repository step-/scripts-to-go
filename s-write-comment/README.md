title: S-WRITE-COMMENT  
date: 2019-11-08  
homepage: <https://github.com/step-/scripts-to-go>  

# s-write-comment

File comment file writer

## Target User

You want to keep comments alongside your files.

You don't have to but if you use ROX-Filer you will get better integration and
enhanced usability.

## Benefits

In essence, this utility does a simple thing: given a target file name, say
`TheFile`, it creates a comment file alongside named `TheFile.txt`, and opens
it in your text editor so you can write your free-form comments.

The advantages in using this utility rather than doing it yourself include:

* Point-and-click interaction and sensible defaults take you to edit your
  comments in just one click.
* A GTK save file dialog allows saving to another folder or with another name.
* The comment file displays as a tooltip in ROX-Filer(*) when the mouse pointer
  hovers over the target file icon.
* ROX-Filer SendTo integration included.
* File system extended attribute (xattr) support.

_(*) Requires a ROX-Filer build patched to enable tooltip comments. The patch is
included in Fatdog64 Linux[:4](#LINKS) and modern Puppy Linux[:8](#LINKS) builds._

## Installing

This script can be installed from a command line shell prompt.
You must install to `/` to enable ROX-Filer integration.

It can be started from a shell prompt.  The installer also adds an _invisible_ "Write Comment"
entry in section "Utility" of the system application menu,
and the ROX-Filer SendTo entry "Add Comment File".

First, install all dependencies --- see section _Dependencies_.

Then download the latest archive **attachment** from the release page[:1](#LINKS).
Unpack the archive into a folder of your choice.

From that folder run the following command: `install/bin/install.sh`.
This will start an interactive installer, which includes a Help screen.

Assuming a successful installation with default settings, you should be able to
run `/usr/local/bin/s-write-comment.sh /path/to/file` to start this utility.

**Important** --- After having completed the installation you **must** save file
`install.log`, which is located in folder `install/`, if you want to be able to
uninstall this program in the future.  Indeed, it is recommended to save the
whole folder `install/`, which holds the uninstall program and the log file.

## Dependencies

Install `yad`[:5](#LINKS).

* This utility, and its dependencies, are already included in Fatdog64 since
  version 720.

For ROX-Filer tooltip support, ROX-Filer must be compiled with the "tooltip comments"
patch. There are at least two kinds of the patch floating around the net:

* Fatdog64 720 and Puppy Linux -- looks for comment file `.TheFile.comment` for
  target file `TheFile`.
* Fatdog64 800 -- looks for comment file `TheFile.txt` for target file `TheFile`.

By default this utility supports both kinds.

## Uninstalling

From the folder where you unpacked the downloaded archive run the following
command: `install/bin/uninstall.sh`.
This will start an interactive uninstaller, which includes a Help screen.

## Configuration through environment variables

**TL;DR** --
For Fatdog64 800+ not to create also a version 720 compatible link file:
add the following line to your user profile file
`~/.fatdog/profile`, log out and log in again:

```sh
export COMMENT_OPTIONS=--no-symlink
```

---

S-write-comment does not provide a user configuration file to set preferences. Instead
it expects preferences to be set in the form of environment variables, which a
user can either set when invoking a single dndmate instance, or set in the user
profile file to affect all future invocations.
(Changes to the user profile file are effective at the next login).

> `COMMENT_EDITOR` -- text editor program path,
> default `defaulttexteditor`.

> `COMMENT_OPTIONS` -- additional command options
> Run `s-write-comment.sh --help` to see available options.

## Help

At a shell prompt run the following line:

    s-write-comment.sh --help

Also this file is "the" help file, so keep it around for future reference
because it isn't installed by default.  However, if the `man` command is
installed, you will be able to view these contents by running command:

    man s-write-comment

## AUTHOR

step

<a name="LINKS">

## LINKS

**Homepage**
[github.com/step-/scripts-to-go](https://github.com/step-/scripts-to-go)

**:1** release page
[github.com/step-/scripts-to-go/releases](https://github.com/step-/scripts-to-go/releases)

**:4** Fatdog64 Linux
[distro.ibiblio.org/fatdog/web/](http://distro.ibiblio.org/fatdog/web/)

**:5** yad - a GTK dialog program
[github.com/v1cont/yad](https://github.com/v1cont/yad/)

* Fatdog64 800 binary package
[distro.ibiblio.org/fatdog/packages/800/yad_gtk2-0.42.0_5](http://distro.ibiblio.org/fatdog/packages/800/yad_gtk2-0.42.0_5-x86_64-1.txz)

* Fatdog64 800 source (the build recipe can be found under `/usr/src` in the binary package)
[distro.ibiblio.org/fatdog/source/800/yad_gtk2-62d54eb5bf5ae2457c6986c33c6de89a6284f969.tar.gz](http://distro.ibiblio.org/fatdog/source/800/yad_gtk2-62d54eb5bf5ae2457c6986c33c6de89a6284f969.tar.gz)

**:8** Puppy Linux
[puppylinux.com](http://puppylinux.com)

* wiki
[puppylinux.org](http://puppylinux.org)

* forum
[murga-linux.com/puppy](http://murga-linux.com/puppy/)
