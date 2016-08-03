# rox-filer-trove

A collection of my Linux scripts.

I develop my scripts mostly for _Fatdog64 Linux_, a _Puppy Linux_ derivative.[1]

These scripts are written to be compatible with the POSIX-compliant ash shell that comes with busybox. The she-bang line is generically set as `#!/bin/sh` to simplify packaging across Linux variants. For scripts that require features of a specific shell, the she-bang is set to reflect which shell, i.e. `#!/bin/bash`.

These scripts assume that the GNU versions of various commands are installed, and that GTK2+ is the GUI toolkit.

[1] Since version 700, Fatdog64 is built from _Linux From Scratch (LFS)_, and maintains excellent compatibility with Puppy Linux.

### roxmm

A ROX-Filer SendTo menu look-alike.
 
 * Installing: `install/install-roxmm.sh`
 * Dependencies: [my gtkmenuplus fork](https://github.com/step-/gtkmenuplus)
 * Help: `roxmm --help`
 * ![Screenshot](img/roxmm.png)
