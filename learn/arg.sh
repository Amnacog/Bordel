#!/bin/zsh
color=0
echo \$0 $0
echo \$\* $*
echo \$@ $@
echo \$# $#
#echo \$? $?
echo \$$ $$
echo \$! $!

for arg in $@; do
	if [ "$arg" = "--color" ]; then color=1 ; fi
done

echo color $color
