#!/bin/dash

# META-begin
# fatdog-wireless-antenna.sh - wifi antenna manager
# Copyright (C) step, 2017
# License: GNU GPL Version 2
  Homepage=https://github.com/step-/scripts-to-go
  Version=1.0.2
# META-end

# exec >>/tmp/${0##*/}.log 2>&1
# echo ========================
# date +%Y%m%d-%H%M%S
# echo "$0 $*"
# echo ========================
# set -x

export TEXTDOMAIN=fatdog-wireless-antenna
export OUTPUT_CHARSET=UTF-8
#NOT-USED . gettext.sh

SHNETLIB_MODE=detailed
. /usr/sbin/shnetlib.sh

export YAD_OPTIONS="--center --buttons-layout=center --window-icon=/usr/local/lib/X11/pixmaps/wifi48.png"

i18n_table() # {{{1
# i18n CAVEAT: Apparently xgettext can't extract strings from 'gettext -es'
# correctly.  Use tool/xgettext.sh instead.
{
  {
    read i18n_main_window_title
    read i18n_interface_name
    read i18n_which
    read i18n_radio_index
    read i18n_module_name
    read i18n_radio_unblocked
    read i18n_radio_blocked_reason
    read i18n_radio_hard_blocked
    read i18n_radio_soft_blocked
    read i18n_radio_hard_and_soft_blocked
    read i18n_rfkill_not_supported
    read i18n_error_operation_failed
    read i18n_button_restart_network
    read i18n_on
    read i18n_off
    read i18n_unknown
    read i18n_tooltip_toggle
    read i18n_restarting_network
    read i18n_network_restarted
    read i18n_network_restarted_timeout
  } << EOF
  $(gettext -es \
  "Wireless Antenna\n" \
  "Interface\n" \
  "Which\n" \
  "Index\n" \
  "Module Name\n" \
  "Antenna\n" \
  "Reason\n" \
  "hard block\n" \
  "soft block\n" \
  "hard block and soft block\n" \
  "rfkill not supported\n" \
  "operation failed\n" \
  "Restart _Network\n" \
  "<b>on</b>\n" \
  "off\n" \
  "unknown\n" \
  "Double-click the row or select it and press Enter to toggle the antenna.\n" \
  "Restarting network...\n" \
  "Network restarted.\r\rIf the wireless network isn't connected, click\rthe wpa_gui tray icon and connect again.\n" \
  "8\n" \
  )
EOF
}

call_restart_app() #{{{1
{
  "$0" &
  sleep 0.2
  kill $YAD_PID
}

call_restart_network() #{{{1
{
  { /etc/init.d/50-Wpagui restart & echo 1; wait; } |
  yad --progress --pulsate --auto-close --on-top --no-buttons \
    --undecorated --no-focus --skip-taskbar --text-align=center --borders=10 \
    --text="$i18n_restarting_network\n"
  yad --text="$i18n_network_restarted\n" --on-top --button=gtk-ok \
    --undecorated                           --text-align=center --borders=10 \
    --image=wpa_gui --image-on-top \
    --timeout="$i18n_network_restarted_timeout" --timeout-indicator=bottom
}

call_update_row() # $@-row {{{1
{
  local op iface=$1 which=$2 rfkill_index=$3 module_name=$4 radio_enabled="$5"
  case "$radio_enabled" in
    "$i18n_unknown" ) return 0 ;;
    "$i18n_on" ) op=block ;;
    "$i18n_off" ) op=unblock ;;
  esac
  # Assert: $which is invariant because enum_interfaces finds the same wireless set.
  enum_interfaces
  if rfkill $op $rfkill_index; then
    print_list_row $which
  else
    print_list_row $which "$i18n_error_operation_failed"
  fi
}

print_list_row() # $1-wireless-iface-which [$2-radio-blocked-reason] {{{1
{
  local which=$1 radio_blocked_reason=$2 radio_unblocked
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
  printf "%s\n" $IFACE_iface $IFACE_which $IFACE_rfkill_index \
    ${IFACE_module_path##*/} "$radio_unblocked" "$radio_blocked_reason" \
    "$i18n_tooltip_toggle"
}

# Main {{{1
i18n_table
if [ $# -gt 0 ]; then "$@"; exit; fi # call_* from yad dialog

enum_interfaces
[ $IFACE_wireless_n = 0 ] && exit

for w in $IFACE_wireless_which; do
  print_list_row $w
done |
yad --list \
  --title="$i18n_main_window_title" --width=400 --height=200 \
  --column="$i18n_interface_name" \
  --column="$i18n_which:HD" \
  --column="$i18n_radio_index:HD" \
  --column="$i18n_module_name" \
  --column="$i18n_radio_unblocked" \
  --column="$i18n_radio_blocked_reason" \
  --column=":HD" --tooltip-column=7 \
  --dclick-action="@$0 call_update_row" \
  --button="gtk-refresh:$0 call_restart_app" \
  --button="$i18n_button_restart_network!wpa_gui:$0 call_restart_network" \
  --button="gtk-quit:0" \
  > /dev/null
