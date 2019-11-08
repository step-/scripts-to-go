#!/bin/dash

# META-begin
# fatdog-wireless-antenna.sh - wifi antenna manager
# Copyright (C) step, 2017-2019
# License: GNU GPL Version 2
  Homepage=https://github.com/step-/scripts-to-go
  Version=1.3.1
# META-end

export TEXTDOMAIN=fatdog
export OUTPUT_CHARSET=UTF-8

SHNETLIB_MODE=detailed
. shnetlib.sh
. yad-lib.sh

LISTF="${TMPDIR:-/tmp}/${0##*/}.$$"
POLLINTERVAL=3
YAD_DEFAULT_POS="--center"

# Efficient way to structure a translation table.
i18n_table() # {{{1
{
# Notes for translators:
# 1. Apparently xgettext doesn't know how to extract strings from calls to
#    'gettext -es'. Therefore this .pot template is generated with
#    usr/share/doc/fatdog-wireless-antenna/xgettext.sh.
# 2. From this point on:
#    A. Never use \n inside your msgstr. You can use \r instead.
#    B. Always end your msgstr with \n.
#    C. Replace trailing spaces (hex 20) with no-breaking spaces (hex A0).
#
  {
    # i18n_YAD_WIDTH in pixels: change the width value for your translation.
    # Note that yad gives the last column all the residual extra space of the
    # other columns. So, the last column, i18n_LAST_COLUMN_FOR_LONG_DETAILS,
    # is used to display the longest (concatenated) messages.
    read i18n_YAD_WIDTH
    read i18n_main_window_title
    read i18n_interface_name
    read i18n_which
    read i18n_radio_index
    read i18n_module_name
    read i18n_radio_unblocked
    read i18n_radio_blocked_reason
    read i18n_LAST_COLUMN_FOR_LONG_DETAILS
    read i18n_radio_hard_blocked
    read i18n_radio_soft_blocked
    read i18n_radio_hard_and_soft_blocked
    read i18n_rfkill_not_supported
    read i18n_operation_not_possible
    read i18n_button_restart_network
    read i18n_on
    read i18n_off
    read i18n_unknown
    read i18n_tooltip_toggle
    read i18n_restarting_network
    read i18n_network_restarted
    read i18n_network_restarted_timeout
    read i18n_wireless_interface_not_found
    read i18n_up
    read i18n_down
    read i18n_dormant
    read i18n_carrier
    read i18n_no_carrier
    read i18n_help_remove_hard_block
    # i18n_list_sep consists of: comma non-breaking space \n
    read i18n_list_sep
    read i18n_Network_Tool
  } << EOF
  $(gettext -es -- \
  "--width=550\n" \
  "Wireless Antenna\n" \
  "Interface\n" \
  "Which\n" \
  "Index\n" \
  "Module Name\n" \
  "Antenna\n" \
  "Block\n" \
  "Details\n" \
  "hard\n" \
  "soft\n" \
  "hard and soft\n" \
  "rfkill not supported\n" \
  "operation not possible\n" \
  "Restart _Network\n" \
  "<b>on</b>\n" \
  "off\n" \
  "unknown\n" \
  "Double-click the row or select it and press Enter to toggle the antenna.\n" \
  "Restarting network...\n" \
  "Network restarted.\r\rIf the wireless network isn't connected, click\rthe %s tray icon and connect again.\n" \
  "8\n" \
  "Wireless interface not found.\n" \
  "up\n" \
  "down\n" \
  "dormant\n" \
  "AP\n" \
  "no AP\n" \
  "Try to remove the hard block of interface %s with shell command rfkill, which could list the interface under different names. Or toggle the physical 'WIFI ON/OFF' switch of your computer.\n" \
  ", \n" \
  "Network Tool\n" \
  )
EOF
}

call_restart_network() #{{{1
# Invoked as: $0 call_restart_network
{
  local res
  yad_lib_set_YAD_GEOMETRY '' '' 50:1:250:::100 && export YAD_GEOMETRY_POPUP
  { echo 1; /etc/init.d/50-Wpagui restart >/dev/null 2>&1 & wait; res=$?; echo 100; } |
  yad $YAD_GEOMETRY_POPUP --progress --pulsate --auto-close --on-top --no-buttons \
    --undecorated --no-focus --skip-taskbar --text-align=center --borders=10 \
    --text="$i18n_restarting_network\n"
  YAD_XID= yad_lib_set_YAD_GEOMETRY '' '' 70:20:450:::100
  yad $YAD_GEOMETRY_POPUP --text="$(printf "$i18n_network_restarted\n" "$i18n_Network_Tool")" --on-top --button=gtk-ok \
    --image=networktool --image-on-top \
    --timeout="$i18n_network_restarted_timeout"
  return $res
}

call_toggle_row() # $@-row {{{1
# Invoked as: $0 call_toggle_row <yad-list-row-fields>
{
  local iface=$1 which=$2 rfkill_index=$3 module_name=$4 radio_enabled="$5" block_reason="$6" operation_details="$7" tooltip="$8" dclick_action="$9"
  local op res s0 s1
  case "$radio_enabled" in
    "$i18n_unknown" ) return 0 ;; # theoretically possible but never seen nor tested.
    "$i18n_on" ) op=block ;;
    "$i18n_off" ) op=unblock ;;
  esac
  enum_interfaces
  # Assert: $which is the clicked row index because enum_interfaces just found
  # the same set of wireless interfaces that was being shown when the row was
  # clicked. If this isn't the case, the user should click Refresh then retry
  # toggling the interface. Verify assertion.
  get_iface_wireless $which
  if [ $iface != $IFACE_iface ]; then
    # Assertion failed. Don't toggle; force refresh instead.
    yad_lib_at_restart_app --exit --yad-pid=$DIALOG_PID
  fi
  # Perform the double-click action.
  # By default toggle the antenna. Request action exceptions via $dclick_action.
  case "$dclick_action" in
    "show tooltip" )
      yad_lib_set_YAD_GEOMETRY '' '' 70:20:450:::100 && export YAD_GEOMETRY_POPUP
      1>&- yad $YAD_GEOMETRY_POPUP --title="$i18n_main_window_title" \
        --text="$tooltip" --on-top --button=gtk-ok --image=gtk-help --image-on-top &
      ;;
    *)
      s0=$IFACE_rfkill_state
      rfkill $op $rfkill_index; res=$?
      get_iface_wireless $which; s1=$IFACE_rfkill_state
      if [ $res = 0 -a $s0 != $s1 ]; then # success: state changed
        print_list_row $which
      else
        if [ 1 = "$IFACE_rfkill_hard" -a "$op" = unblock ]; then
          tooltip="$(printf "$i18n_help_remove_hard_block" $IFACE_iface)"
        fi
        print_list_row $which "<span color='red'>$i18n_operation_not_possible</span>" "$tooltip" "show tooltip"
      fi
      ;;
  esac
  return 0 # yad's 'call_' callback must exit 0.
}

print_list_row() # $1-wireless-iface-which [$2-operation_details $3-tooltip $4-dclick_action] {{{1
{
  local which=$1 operation_details="$2" tooltip="$3" dclick_action="$4"
  local radio_unblocked details
  get_iface_wireless $which
  unset radio_blocked_reason
  case $IFACE_rfkill_state in
    '' )
      radio_unblocked="$i18n_unknown"
      radio_blocked_reason="$i18n_rfkill_not_supported"
      ;;
    1 )
      radio_unblocked="$i18n_on"
      ;;
    * )
      radio_unblocked="$i18n_off"
      if ! [ "$radio_blocked_reason" ]; then
        case $IFACE_rfkill_hard$IFACE_rfkill_soft in
          10 ) radio_blocked_reason="$i18n_radio_hard_blocked" ;;
          01 ) radio_blocked_reason="$i18n_radio_soft_blocked" ;;
          11 ) radio_blocked_reason="$i18n_radio_hard_and_soft_blocked" ;;
        esac
      fi
      ;;
  esac
  case $IFACE_operstate in
    up ) details="$i18n_up" ;;
    down ) details="$i18n_down" ;;
    dormant) details="$i18n_dormant" ;;
    * ) details="$i18n_unknown" ;;
  esac
  if [ -z "$operation_details" ]; then
    # Default text for column $i18n_LAST_COLUMN_FOR_LONG_DETAILS ("Details").
    if [ 1 = $IFACE_carrier ]; then
      # Show carrier detected and possibly IP address.
      set -- $(ip -o -4 addr show $IFACE_iface) # TODO add IP6 (polling loop too)
      x="${4%/*}"
      [ "$x" ] && details="$x" || details="$details$i18n_list_sep$i18n_carrier"
    else
      details="$details$i18n_list_sep$i18n_no_carrier"
    fi
  else
    details="$operation_details"
  fi
  printf "%s\n" $IFACE_iface $IFACE_which $IFACE_rfkill_index \
    ${IFACE_module_path##*/} "$radio_unblocked" "$radio_blocked_reason" \
    "$details" "${tooltip:-$i18n_tooltip_toggle}" "$dclick_action"
}

# Main {{{1
i18n_table
YAD_TITLE=$i18n_main_window_title # for yad_lib_set_YAD_GEOMETRY
export YAD_OPTIONS="--gtkrc=$STYLEFILE --borders=4 --buttons-layout=center --window-icon=/usr/local/lib/X11/pixmaps/wifi48.png"
yad_lib_dispatch "$@"
if [ $# -gt 0 ]; then "$@"; exit $?; fi # call_* from yad dialog

enum_interfaces
if [ $IFACE_wireless_n = 0 ]; then
  yad_lib_set_YAD_GEOMETRY
  yad ${YAD_GEOMETRY_POPUP:-$YAD_DEFAULT_POS} --text "$i18n_wireless_interface_not_found" \
    --undecorated --text-align=center --borders=10 \
    --image=networktool --image-on-top \
    --timeout="$i18n_network_restarted_timeout" \
    --button=gtk-ok
  exit
fi

trap "rm -f '${LISTF:----}'*; exit 0" HUP INT QUIT TERM ABRT 0
for w in $IFACE_wireless_which; do
  print_list_row $w
done > "$LISTF"-in
! [ -s "$LISTF"-in ] && exit 3

# Show dialog. {{{2
# start_geometry frames this dialog and all its children dialogs.
start_geometry="${YAD_GEOMETRY:-$YAD_DEFAULT_POS $i18n_YAD_WIDTH}"
# Note: $i18n_LAST_COLUMN_FOR_LONG_DETAILS must be the last _visible_ column
# because that position gathers all the residual unused widths from the other
# visible columns, and if there is residual space the last column can expand -
# within the fixed-size width $i18n_YAD_WIDTH. See also print_list_row().

< "$LISTF"-in yad $start_geometry --title="$YAD_TITLE" \
  --list \
  --column="$i18n_interface_name" \
  --column="$i18n_which":HD \
  --column="$i18n_radio_index":HD \
  --column="$i18n_module_name" \
  --column="$i18n_radio_unblocked" \
  --column="$i18n_radio_blocked_reason" \
  --column="$i18n_LAST_COLUMN_FOR_LONG_DETAILS" \
  --column="tooltip":HD --tooltip-column=8 \
  --column="dclick-action":HD \
  --dclick-action="@$0 call_toggle_row" \
  --button="gtk-refresh:$0 yad_lib_at_restart_app --exit" \
  --button="$i18n_button_restart_network!networktool:$0 call_restart_network" \
  --button="gtk-quit:0" \
  > /dev/null & sleep 0.2
DIALOG_PID=$!

# Monitor dialog exit and interface state changes (up/down/IP address). {{{2
pstate="$IFACE_wireless_path$IFACE_wireless_carrier$IFACE_wireless_operstate $(ip -o -4 addr)"
state="$pstate"
while [ "$state" ]; do
  ! ps $DIALOG_PID >/dev/null && exit 4
  ! [ "$pstate" = "$state" ] && yad_lib_at_restart_app --exit=5 --yad-pid=$DIALOG_PID
  sleep $POLLINTERVAL
  enum_interfaces
  state="$IFACE_wireless_path$IFACE_wireless_carrier$IFACE_wireless_operstate $(ip -o -4 addr)"
done
