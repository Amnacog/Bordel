#!/bin/bash
echo -en "\E[6n"
read -sdR cur
cur=${cur#*[}

echo "$(echo $cur | cut -d';' -f2) $(echo $cur | cut -d';' -f1)"
