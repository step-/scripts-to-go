# This file is sourced not run.

# Package-specific action hooks.
# The installer will call these functions at well-defined points (see install.sh).
# Copy this file to package-functions.sh, uncomment and define the functions you need.
# They can create temporary files in a sub-folder of $TMPD, e.g, "$TMPD/package",
# which will be automatically deleted on exit.

# package_pre_install_test () {
#   print_reverse "*** triggers right before the install test"
# }

# package_post_install_test () {
#   print_reverse "*** triggers right after the install test"
# }

package_install_test_result_prologue () {
#   print_reverse "*** triggers at the top of the install test result page"
  cat << 'EOF'
____
PACKAGE QUICKLAUNCH - RECOMMENDED INSTALLATION SETTINGS:

Destination : /  install system-wide themes and manual page[1]
Home        :    leave empty for first-time installation[2]

[1] Installing to "/" requires user root's capability (su or sudo).
[2] The installer will add files to your home folder. To install
    into another user's home folder run subsequently:
    ./install/bin/install.sh --skip-dest / ~User:User.Group
    (replace User and Group with a user's actual name and group).
EOF
}

# package_install_test_result_epilogue () {
#   print_reverse "*** triggers at the bottom of the install test result page"
# }

# package_pre_install_dest () {
#   print_reverse "*** triggers right before installing to /Destination/Dir"
# }

# package_post_install_dest () {
#   print_reverse "*** triggers right after installing to /Destination/Dir"
# }

# package_pre_install_home () {
#   print_reverse "*** triggers right before installing to /Home/Dir"
# }

package_post_install_home () {
#   print_reverse "*** triggers right after installing to /Home/Dir"
	if ! [ -e "$HOME_DIR"/quicklaunch-user.gtkmenuplus ]; then
		cat << 'EOF' > "$HOME_DIR"/quicklaunch-user.gtkmenuplus
# quicklaunch.gtkmenuplus includes this file before the first separator.
# Add here your personal menu items.
EOF
	fi
	if ! [ -e "$HOME_DIR"/quicklaunch-user-var.gtkmenuplus ]; then
		cat << 'EOF' > "$HOME_DIR"/quicklaunch-user-var.gtkmenuplus
# See the Tools>Help menu entry.

# defaultbrowser=firefox
# defaulttexteditor=geany
# RECENTFILE=$_HOME/.gmenu2.log
# PRUNEREX="@prune_this@|Item=(Reboot|Restart X|Shutdown|Suspend)"
# SHOW_LAST_N_COMMANDS=1
EOF
	fi
	if ! [ -e "$HOME_DIR"/quicklaunch-user-theme-gtkrc ]; then
		ln -sfT /usr/share/themes/Quicklaunch-ambiance/gtk-2.0/gtkrc "$HOME_DIR"/quicklaunch-user-theme-gtkrc
	fi
}

package_installer_exit () {
#   print_reverse "*** triggers at the very end"
  cat << EOF
____
PACKAGE QUICKLAUNCH - FINAL NOTES

Don't forget to save the installation folder ./install to a safe
place if you intend to run the uninstaller at a later time.

Thank you for trying QUICKLAUNCH.  For help run:
  man quicklaunch
  man 5 gtkmenuplus
EOF
}

