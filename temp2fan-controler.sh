#!/bin/bash

# Working directoy
cd /sys/devices/platform/applesmc.768

CURRENT_MAX_TEMP="$(sensors | grep T | grep + | tr -d '+' | tr -d ' ' | cut -d '=' -f2 | tr -d 'C' | cut -d ':' -f 2 | cut -d '.' -f 1 | sort -nr | head -1)"

FAN_NUMBERS="$(ls -1 fan*_input | wc -l)"

set_max_and_min_rpm_variable () {
  i=1
  for fan in fan*_min
  do
    echo "$((FAN_${i}_MIN_RPM = "$(cat $fan)"))" 1> /dev/null
    ((i = i + 1))
  done

  i=1
  for fan in fan*_max
  do
    echo "$((FAN_${i}_MAX_RPM = "$(cat $fan)"))" 1> /dev/null
    ((i = i + 1))
  done
}

set_max_and_min_rpm_variable

# revisar el sh the testif en imac, esta hecho
# falta revisiar la condicion de entrada con regez para aceptar solo integers entre 0-100
calculate_fan_rpm_based_on_porcentage () {
# $1 -> porcetnje
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
  # cd /sys/devices/platform/applesmc.768
  # $1 -> porcentaje 
  # aplica el mismo porcentaje a todos los ventiladores
  i=1
  for fan in fan*_output
  do
    calculate_fan_rpm_based_on_porcentage $1 $i > $fan
    ((i = i + 1))
  done
}

#controlador 
## comparar temperatura max actual con temperatura deseada, ya sea por tabla o por formula
## calcular la nueva rpm basado en min y max de cada fan. por porcentajes
# de aqui se llama a set nuevo fan rpm


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

# crear una funcion que genere un log
echo -n "$(date): "
echo -n "Current Max. Temp.:${CURRENT_MAX_TEMP}ºC. "
echo -n "Fans detected:${FAN_NUMBERS}. "

discrete_controler_temp2fan

echo ''
exit 0