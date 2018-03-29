#!/bin/bash
i=0
max=100
e=0
if [ "$#" -eq 0 ]; then
   while :
   do
      if [ $i -ne $max ] && [ $e -eq 0 ]; then
         e=0
         ((i++))
      else
         e=1
         ((i--))
         if [ $i -eq 1 ]; then e=0 ; fi
      fi
      echo -n $(date | cut -d' ' -f4)
      printf %$i\s |tr " " "-"
      echo
   done
else
    while :
    do
      sec=$(date +"%S")
      if [ "$sec" == "00" ]; then e=1 ; fi
      if [ "$sec" == "10" ]; then e=0 ; fi
      if [ $e -eq 1 ]; then sec=$(echo $sec | cut -d'0' -f2); fi

      echo -n $(date | cut -d' ' -f4)
      printf %$sec\s |tr " " "-"
      echo ""
      sleep 1
    done
fi
