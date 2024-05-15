# YeelightController

Simple shell utility to discover and control Yeelight Wifi Smart bulb

Please read the [blog post](https://shyamvalsan.com/blog/yeelightwifiraspberrypi/) for more details on this project.

## Install

Just copy the files in this repo to your linux machine, the utilities used by the code
are shell, awk, netcat, arp - all of which should be bundled with your OS.

## Run

1.  Plug in the yeelight smart bulb
2.  Turn on the light switch
3.  Run ./light.sh -h for options on how to control the bulb

```
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
    [brightness] <level> - set the brightness to <level> from 1 (dimmest) to 100 (brightest), keyword is optional
    <colors>: black,white,red,lime,blue,yellow,cyan,magenta,silver,gray,maroon,olive,green,purple,teal,navy
```

## Demo

<a href="http://www.youtube.com/watch?feature=player_embedded&v=EqDKSsEf1HE
" target="_blank"><img src="http://img.youtube.com/vi/EqDKSsEf1HE/0.jpg" 
alt="Demo video of Yeelight smart light controller on Raspberry Pi" width="240" height="180" border="10" /></a>

## Multiple smart bulbs control

The next command will set the red color for the lamps 192.168.88.51..54

```
parallel -j0 ./light.sh 192.168.88.5{} red ::: {4..1}
```
