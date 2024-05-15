#!/bin/sh
# Simple script to control Yeelight over wifi

# Color values
# white;0xFFFFFF
# red;0xFF0000
# lime;0x00FF00
# blue;0x0000FF
# yellow;0xFFFF00
# cyan;0x00FFFF
# magenta;0xFF00FF
# silver;0xC0C0C0
# gray;0x808080
# maroon;0x800000
# olive;0x808000
# green;0x008000
# purple;0x800080
# teal;0x008080
# navy;0x000080

# The ip and command is provided as input by the user to this script
ip=$1
command=$2

send_command() {
    printf '{"id": 1, "method":"%s", "params":[%s]}\r\n' "$1" "$2" | nc -w 1 "$ip" 55443
}

color_to_int() {
    color_hex=$(grep -m1 -i "^# $1;" "$0" | cut -d ';' -f 2)
    printf '%d' "$color_hex"
}

# If the command is a known color name, assume the 'color' command
if grep -m1 -q -i "^# $command;" "$0"; then
    color=$command
    command="color"
else
    color=$3
fi
# If the command is a number, assume the 't' or 'brightness' commands
if grep -qE '^[0-9]+$' <<< "$command" 2>/dev/null; then
  num=$command
  # If 0 < command <= 100, assume the 'brightness' commands else assume the 't' command
  [ "$command" -ge 1 ] && [ "$command" -le 100 ] && command="brightness" || command="t"
else
  num=$3
fi

case $command in
"on"|"off")
 send_command set_power '"'"$command"'","smooth",500'
 ;;
"color")
 send_command set_scene '"color", '"$(color_to_int "$color")"', 100'
 ;;
 't')
 send_command set_ct_abx ''"$num"', "smooth", 500'
 ;;
"disco")
 send_command start_cf '50, 0, "100, 1, 255, 100, 100, 1, 32768, 100, 100, 1, 16711680, 100"'
 ;;
"sunrise")
 send_command start_cf '3, 1, "50, 1, 16731392, 1, 360000, 2, 1700, 10, 540000, 2, 2700, 100"'
 ;;
"notify-"*)
 color=$(color_to_int "${command#notify-}")
 send_command start_cf '5, 0, "100, 1, '"$color"', 100, 100, 1, '"$color"', 1"'
 ;;
 "dim")
 send_command set_bright 5
 ;;
 "undim")
 send_command set_bright 100
 ;;
"brightness")
 send_command set_bright "$num"
 ;;
*)
 printf "
light.sh <ip> [command] <color> -- utility to control Yeelight smart bulb over wifi

where command can have one of the following values:
    on - turn on the light
    off - turn off the light
    [color] <color> - set the color to <color>, keyword is optional
    [t] <number> - set the white light temperature to 1700..6500, keyword is optional
    disco - turns on disco mode
    sunrise - turns on sunrise mode
    notify-<color> - notification in <color>
    dim - dim light to brightness 5
    undim - reset light to brightness 100
    [brightness] <level> - set the bgit purightness to <level> from 1 (dimmest) to 100 (brightest), keyword is optional
    <colors>: %s
" "$(awk '/^# Color values/ {flag=1; next} /^$/ {flag=0} flag' light.sh | cut -d ';' -f 1 | cut -d ' ' -f 2 | tr -s '\n' ',' | sed 's/,$//')"
;;
esac