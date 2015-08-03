#!/bin/bash
#
# Does almost what it says: creating folders from a to z in no time :)
#
# Version: 1.0
# Author: Reto Hugi (http://hugi.to/blog/)
# License: GPL v3 (http://www.gnu.org/licenses/gpl.html)
#
#
# Changelog:
# too old to remember... ;-)

folders=( a b c d e f g h i j k l m n o p q r s t u v w x y z )

i=0

while [ $i -lt 26 ]
do
  mkdir -v ${folders[i]}
  let "i+=1"
done
exit 0
