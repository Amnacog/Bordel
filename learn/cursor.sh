#!/bin/bash
old_settings=$(stty -g) || exit
stty -icanon -echo min 0 time 3 || exit
printf '\033[6n'
pos=$(dd count=1 2> /dev/null)
pos=${pos%R*}
pos=${pos##*\[}
x=${pos##*;} y=${pos%%;*}
stty "$old_settings"
echo $x $y
