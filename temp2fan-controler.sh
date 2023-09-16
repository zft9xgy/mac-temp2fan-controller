#!/usr/bin/env bash

# Working directoy
#cd /sys/devices/platform/applesmc.768

# Variables
PATH_CONFIG="/etc/temp2fan.conf"
PATH_APPLESMC="/sys/devices/platform/applesmc.768/"

CURRENT_MAX_TEMP="$(sensors | grep T | grep + | tr -d '+' | tr -d ' ' | cut -d '=' -f2 | tr -d 'C' | cut -d ':' -f 2 | cut -d '.' -f 1 | sort -nr | head -1)" 
FAN_NUMBERS="$(ls -1 /sys/devices/platform/applesmc.768/fan*_input | wc -l )"

CONTROLER_MODE="$( cat ${PATH_CONFIG} | grep -i controler_model | tr -d ' ' | cut -d '=' -f 2 )"

set_max_and_min_rpm_variable () {
  i=1
  for fan in ${PATH_APPLESMC}fan*_min
  do
    echo "$((FAN_${i}_MIN_RPM = "$(cat $fan)"))" 1> /dev/null
    ((i = i + 1))
  done

  i=1
  for fan in ${PATH_APPLESMC}fan*_max
  do
    echo "$((FAN_${i}_MAX_RPM = "$(cat $fan)"))" 1> /dev/null
    ((i = i + 1))
  done
}


calculate_fan_rpm_based_on_porcentage () {
# $1 -> percentage
# $2 > fan number

fanPrefix="FAN_${2}"
minSuffix="_MIN_RPM"
maxSuffix="_MAX_RPM"

 if [ $1 -le 0 ] || [ $1 -gt 100 ]
  then
    echo "$(( $fanPrefix$minSuffix ))"
  else
    echo "$(( (( ( $1 *  ( $fanPrefix$maxSuffix - $fanPrefix$minSuffix )) / 100) + $fanPrefix$minSuffix ) ))"
  fi
}


set_new_rpm () {
  # $1 -> percentage 
  # apply same percentage to all fans
  i=1
  for fan in ${PATH_APPLESMC}fan*_output
  do
    calculate_fan_rpm_based_on_porcentage $1 $i > $fan
    ((i = i + 1))
  done
}

#controler models

discrete_controler_temp2fan () {
  if [ $CURRENT_MAX_TEMP -le 65 ]
  then
    echo -n "Fans set at: min. "
    set_new_rpm 0
  fi

  if [ $CURRENT_MAX_TEMP -gt 65 ] && [ $CURRENT_MAX_TEMP -le 70 ]
  then
    echo -n "Fans set at: 25%. "
    set_new_rpm 25
  fi

  if [ $CURRENT_MAX_TEMP -gt 70 ] && [ $CURRENT_MAX_TEMP -le 75 ]
  then
    echo -n "Fans set at: 50%. "
    set_new_rpm 50
  fi

  if [ $CURRENT_MAX_TEMP -gt 75 ] && [ $CURRENT_MAX_TEMP -le 80 ]
  then
    echo -n "Fans set at: 75%. "
    set_new_rpm 75
  fi

  if [ $CURRENT_MAX_TEMP -gt 80 ] && [ $CURRENT_MAX_TEMP -le 85 ]
  then
    echo -n "Fans set at: 85%. "
    set_new_rpm 85
  fi

  if [ $CURRENT_MAX_TEMP -gt 85 ]
  then
    echo -n "Fans set at: 100%. "
    set_new_rpm 100
  fi
}



# This is a linear controler for 0% rpm at 65C and 100% at 85C
linear_controler_temp2fan () {

  if [ $CURRENT_MAX_TEMP -lt 65 ]
  then 
    echo -n "Fans set at: 0%. "
   set_new_rpm 0
  fi
  if [ $CURRENT_MAX_TEMP -gt 85 ]
  then
    echo -n "Fans set at: 100%. "
    set_new_rpm 100
  fi

  echo -n "Fans set at: $(( 5 * $CURRENT_MAX_TEMP - 325 ))%. "
  set_new_rpm "$(( 5 * $CURRENT_MAX_TEMP - 325 ))"

}

# MAIN EXECUTION

set_max_and_min_rpm_variable

case $CONTROLER_MODE in
    1)
        discrete_controler_temp2fan
        ;;
    2)
        linear_controler_temp2fan
        ;;
    *)
        discrete_controler_temp2fan
        ;;
esac

echo ''
exit 0