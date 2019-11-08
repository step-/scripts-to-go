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
PACKAGE DNDMATE - RECOMMENDED INSTALLATION SETTINGS:

Destination : /  install required files[1]
Home        :    not needed

[1] Installing to "/" requires user root's capability (su or sudo).
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

# package_post_install_home () {
#   print_reverse "*** triggers right after installing to /Home/Dir"
# }

package_installer_exit () {
#   print_reverse "*** triggers at the very end"
  cat << EOF
____
PACKAGE DNDMATE - FINAL NOTES

Don't forget to save the installation folder ./install to a safe
place if you intend to run the uninstaller at a later time.

Thank you for trying DNDMATE.  For help run:
  man dndmate
EOF
}

