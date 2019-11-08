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

# package_install_test_result_prologue () {
#   print_reverse "*** triggers at the top of the install test result page"
# }

# package_install_test_result_epilogue () {
#   print_reverse "*** triggers at the bottom of the install test result page"
  if ! command -v mpg123 >/dev/null; then
    cat << EOF
____
Optionally install the mpg123 command-line MP3 player (recommended).
Details vary by OS distribution.
Fatdog64 800 already includes mpg123 in the base OS.
For Fatdog64 7xx, install mpg123 from the gslapt package manager:
. Click the system menu Fatdog64 icon
. Click Setup > Gslapt Package Manager
. Click Update, search for "mpg123" (without quotes), select
  version 1.23.8 or higher, right-click to install, click Execute

Direct download link for Fatdog 7xx series:
http://distro.ibiblio.org/fatdog/contrib/packages/710/mpg123-1.23.8-x86_64-1.txz
EOF

  fi
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
PACKAGE TRAY-RADIO - FINAL NOTES

Don't forget to save the installation folder ./install to a safe
place if you intend to run the uninstaller at a later time.

Thank you for trying TRAY-RADIO.  For help run:
  ${DEST_DIR%/}/usr/bin/tray-radio --help
  man tray-radio
EOF
}

