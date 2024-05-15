#!/bin/sh
# Simple script to control Yeelight over wi-fi

# Color values
read -r -d '' colors << EOF
amber;0xFFBF00
blue;0x0000FF
cyan;0x00FFFF
dandelion;0xF0E130
emerald;0x50C878
flamingo;0xFC8EAC
green;0x00FF00
honeydew;0xF0FFF0
indigo;0x4B0082
jade;0x00A86B
khaki;0xC3B091
lavender;0xE6E6FA
magenta;0xFF00FF
navy;0x000080
olive;0x808000
purple;0x800080
quartz;0x51484F
red;0xFF0000
silver;0xC0C0C0
teal;0x008080
ultramarine;0x3F00FF
violet;0xEE82EE
white;0xFFFFFF
xanadu;0x738678
yellow;0xFFFF00
zinnwaldite;0x2C1608
EOF

# The ip and command is provided as input by the user to this script
ip=$1
# If no command is provided, assume the 'help' command
[ -z "$2" ] && command="help" || command=$2

send_command() {
    printf '{"id": 1, "method":"%s", "params":[%s]}\r\n' "$1" "$2" | nc -w 1 "$ip" 55443
}

color_to_int() {
    color_hex=$(grep "$1" <<< "$colors" | cut -d';' -f2)
    printf '%d' "$color_hex"
}

# If the command is a known color name, assume the 'color' command
if grep -qi "^$command" <<< "$colors" ; then
    color=$command
    command="color"
else
    color=$3
fi
# If the command is a number, assume the 't' or 'brightness' commands
if grep -qE '^[0-9]+$' <<< "$command" 2>/dev/null; then
  num=$command
  # If 1 <= command <= 100, assume the 'brightness' command else assume the 't' command
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
light.sh <ip> [command|<color>|<t>|<brightness>] -- utility to control Yeelight smart bulb over wi-fi

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
    [brightness] <level> - set the britness to <level> from 1 (dimmest) to 100 (brightest), keyword is optional
    <color>: %s
" "$(tr '\n' ',' <<< "$colors" | sed 's/;0x[0-9A-Fa-f]*//g' | sed 's/,$//'
)"
;;
esac