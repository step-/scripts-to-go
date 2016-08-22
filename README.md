# Scripts To Go

_Are you sated?_

I develop my scripts mostly for _Fatdog64 Linux_, a _Puppy Linux_ derivative.[1]

They are written to be compatible with the POSIX-compliant _ash_ shell, which comes with busybox. The she-bang line is generically set as `#!/bin/sh` to simplify packaging across Linux variants. For scripts that require features of a specific shell, the she-bang is set to reflect which shell, i.e. `#!/bin/bash`.

These scripts assume the GNU version of various shell commands, and GTK2+ as the GUI toolkit.

Unless otherwise noted, they are licensed under the GNU GPLv3 license.

[1] Since version 700, Fatdog64 is built from _Linux From Scratch (LFS)_, and maintains excellent compatibility with Puppy Linux.

### gmenu2

An application menu.
 
 * Installing: `install/install-gmenu2.sh`
 * Dependencies: [my gtkmenuplus fork](https://github.com/step-/gtkmenuplus)
 * Help: Hover over menu entries for tooltip help.
 * Thanks: Gmenu2 was inspired by SFR's GMenu script.
 * Screenshot: Note the typical Puppy Linux application sub-menus, and
   the additional 'Uncategorized', 'Wine', and 'Gmenu2' sub-menus.
 * ![Screenshot](img/gmenu2.png)


### roxmm

A ROX-Filer SendTo menu look-alike.
 
 * Installing: `install/install-roxmm.sh`
 * Dependencies: [my gtkmenuplus fork](https://github.com/step-/gtkmenuplus)
 * Help: `roxmm --help`
 * Screenshot: Right - rox SendTo menu. Left - corresponding roxmm menu. Note tooltip and Tools menu.
 * ![Screenshot](img/roxmm.png)
