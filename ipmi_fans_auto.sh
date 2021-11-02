#!/bin/bash
#arrayStarted=true
#clearLog=true
#noParity=false

# SuperMicro IPMI Auto(-ish) Fan Control
# Check current CPU package temps and updates fan duty cycles based on adjustable thresholds
# 
# This requires ipmitool to be installed (Unraid users: install this through the NerdPack GUI plugin)
#
# It is HIGHLY recommended to set this script to run on a cron schedule (e.g. "*/5 * * * *" for every 5 minutes)
# If set using the "User Scripts" plugin on Unraid, this will not store logs other than the most recent run.
#
# NOTE: The SuperMicro IPMI fan mode -MUST- be set to "Full Speed Mode" for ipmitool to control fan speeds
# It is recommended to use a separate script (see end of this script) to force "Full Speed Mode" on startup 
# instead of adding that command in this script. If you put the required command in this script, 
# then your fans will always go to max speed for a few seconds every time this script runs.
#
# NOTE: This will only use CPU package temperatures to determine what fan speeds should be set, 
# but advanced users should be able to adapt this to other sensors easily enough.

###########################
## STARTUP COMPANION SCRIPT
## Copy this commented portion into its own **SEPARATE** script that runs on startup.
## (Unraid users: Use "User Scripts" and set to run on array startup)
## This will ensure the IPMI fan mode is always on the required "Full Speed" mode, which
## is a requirement to manually adjust fan speeds via ipmitool for SuperMicro IPMI
## (You MUST uncomment the five lines below with a single #)
##
## Set IPMI fan mode to "full"
#ipmitool raw 0x30 0x45 0x01 0x01
#sleep 1
## final value below is duty cycle (0x00-0x64)
## CPU Zone duty cycle to 50%
#ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x32
#sleep 1
## Peripheral Zone duty cycle to 50%
#ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x32
###########################


## TEMPERATURE THRESHOLDS
# These are the thresholds for when fan speed should change (in degrees Celsius)
#
# CPU thresholds will change both fan zones
cpu_thresh_hot1=65
cpu_thresh_hot2=70
cpu_thresh_hot3=75
cpu_thresh_crit=80

# Disk thresholds will only change the peripheral fan zone,
# and only if higher disk threshold than the CPU threshold
disk_thresh_hot1=45
disk_thresh_hot2=50
disk_thresh_hot3=55
disk_thresh_crit=60

## FAN DUTY CYCLES
#
# Fan Zones on SuperMicro boards are based on the Motherboard's Fan Header labels
# The CPU Fan Zone (i.e. FAN1, FAN2, etc.) and Peripheral Fan Zone (i.e. FANA, FANB, etc.)
# duty cycles are declared separately so you can tune them for different noise levels.
# BOTH zones get set every time the script is run.
#
# SuperMicro IPMI fan duty cycles are set with a value between '0x00'-'0x64'
# EXAMPLES: 0x00 = 0% duty cycle, 0x32 = 50%, 0x64 = 100%
# NOTE: 'cool' cycles are for when temperatures are below 'hot1' thresholds
#
# CPU Fan Duty Cycles 
fan_cpus_cool='0x32'
fan_cpus_hot1='0x36'
fan_cpus_hot2='0x40'
fan_cpus_hot3='0x48'
fan_cpus_crit='0x56'

# Peripheral Fan Duty Cycles 
fan_peri_cool='0x32'
fan_peri_hot1='0x36'
fan_peri_hot2='0x40'
fan_peri_hot3='0x48'
fan_peri_crit='0x56'


## CPU PACKAGE TEMPERATURE SENSORS
# Open a console and run "sensors -j" and inspect the JSON output. 
# You need to find each CPU's JSON name (i.e. "coretemp-isa-0000") -AND- it's corresponding Package temp name (i.e. "Package id 0") and input them below
#
# If you only have a single physical CPU: 
#      Update cpu0temp JSON values to match those you found, and set "cpu1temp=0" rather than commenting it out to avoid needing to edit any more
# If you have 3 or 4 physical CPUs: 
#      Update cpu0temp & cpu1temp JSON values to match those you found. Copy the command from either of them down to corresponding cpu2temp/cpu3temp and update JSON values
# If you somehow have more than 4 physical CPUs in your system:
#      Add additional cpu#temp variables below and ALSO add the new variables to the 'cputemps' array

#cputempexample=$(sensors -j | jq '. | {temp1_input: ."coretemp-isa-0000"."Package id 0".temp1_input}' | awk 'match($0,/\"temp1_input\": ([0-9]+)/,a){print a[1]}')
cpu0temp=$(sensors -j | jq '. | {temp1_input: ."coretemp-isa-0000"."Package id 0".temp1_input}' | awk 'match($0,/\"temp1_input\": ([0-9]+)/,a){print a[1]}')
cpu1temp=$(sensors -j | jq '. | {temp1_input: ."coretemp-isa-0001"."Package id 1".temp1_input}' | awk 'match($0,/\"temp1_input\": ([0-9]+)/,a){print a[1]}')
cpu2temp=0
cpu3temp=0

cputemps=($cpu0temp $cpu1temp $cpu2temp $cpu3temp)


## DISK TEMPERATURE SENSORS
# Update the entries below to point to your drives by label (/dev/sda, /dev/sdb, etc.)
# If you have more than 24 drives:
#      Add additional disk##temp variables below and ALSO add the new variables to the 'disktemps' array
# If you do not want to monitor disk speeds

#disktemexample=$(smartctl -A /dev/sdx | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk01temp=$(smartctl -A /dev/sdb | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk02temp=$(smartctl -A /dev/sdc | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk03temp=$(smartctl -A /dev/sdd | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk04temp=$(smartctl -A /dev/sde | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk05temp=$(smartctl -A /dev/sdf | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk06temp=$(smartctl -A /dev/sdg | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk07temp=$(smartctl -A /dev/sdh | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk08temp=$(smartctl -A /dev/sdj | awk 'BEGIN{t="*"} $1==190||$1==194{t=$10;exit};$1=="Temperature:"{t=$2;exit} END{print t}')
disk09temp=0
disk10temp=0
disk11temp=0
disk12temp=0
disk13temp=0
disk14temp=0
disk15temp=0
disk16temp=0
disk17temp=0
disk18temp=0
disk19temp=0
disk20temp=0
disk21temp=0
disk22temp=0
disk23temp=0
disk24temp=0


disktemps=($disk01temp $disk02temp $disk03temp $disk04temp $disk05temp \
           $disk06temp $disk07temp $disk08temp $disk09temp $disk10temp \ 
		   $disk11temp $disk12temp $disk13temp $disk14temp $disk15temp \ 
           $disk16temp $disk17temp $disk18temp $disk19temp $disk20temp \ 
           $disk21temp $disk22temp $disk23temp $disk24temp )

##################################################
#####  YOU DO NOT NEED TO MODIFY BELOW THIS  #####
##################################################
# Gets the maximum CPU package temp
maxcputemp=0
for cputemp in ${cputemps[@]}; do
	if (( $cputemp > 0 )); then echo "CPU temp found: " $cputemp; fi;
	if (( $cputemp > $maxcputemp )); then maxcputemp=$cputemp; fi; 
done
echo "Max CPU Package temp determined: " $maxcputemp

if [[ $maxcputemp -ge $cpu_thresh_hot1 ]]
then
  if [[ $maxcputemp -ge $cpu_thresh_hot2 ]]
  then
    if [[ $maxcputemp -ge $cpu_thresh_hot3 ]]
    then
      if [[ $maxcputemp -ge $cpu_thresh_crit ]]
      then
        echo "ABOVE CRITICAL CPU TEMPERATURE THRESHOLD: " $cpu_thresh_crit
        found_cpu_threshold=4
      else
        echo "Above HOT3 CPU temperature threshold: " $cpu_thresh_hot3
        found_cpu_threshold=3
      fi
    else
      echo "Above HOT2 CPU temperature threshold: " $cpu_thresh_hot2
      found_cpu_threshold=2
    fi
  else
    echo "Above HOT1 CPU temperature threshold: " $cpu_thresh_hot1
    found_cpu_threshold=1
  fi
else
  echo "All CPUs are below " $cpu_thresh_hot1 " degree HOT1 temperature threshold."
  found_cpu_threshold=0
fi

# Gets the maximum disk temp
maxdisktemp=0
for disktemp in ${disktemps[@]}; do
    if (( $disktemp > 0 )); then echo "Disk temp found: " $disktemp; fi;
    if (( $disktemp > $disktemps )); then maxdisktemp=$disktemp; fi; 
done
echo "Max disk temp determined: " $maxdisktemp

if [[ $maxdisktemp -ge $disk_thresh_hot1 ]]
then
  if [[ $maxdisktemp -ge $disk_thresh_hot2 ]]
  then
    if [[ $maxdisktemp -ge $disk_thresh_hot3 ]]
    then
      if [[ $maxdisktemp -ge $disk_thresh_crit ]]
      then
        echo "ABOVE CRITICAL DISK TEMPERATURE THRESHOLD: " $disk_thresh_crit
        found_disk_threshold=4
      else
        echo "Above HOT3 disk temperature threshold: " $disk_thresh_hot3
        found_disk_threshold=3
      fi
    else
      echo "Above HOT2 disk temperature threshold: " $disk_thresh_hot2
      found_disk_threshold=2
    fi
  else
    echo "Above HOT1 disk temperature threshold: " $disk_thresh_hot1
    found_disk_threshold=1
  fi
else
  echo "All disks are all below " $disk_thresh_hot1 " degree HOT1 temperature threshold."
  found_disk_threshold=0
fi

## DETEMRINE THE FAN SPEEDS
# CPU zone speed is always determined by CPU threshold
new_cpu_fan_speed=$found_cpu_threshold

if [[ $found_cpu_threshold -ge $found_disk_threshold ]]
then
  # If cpu temp threshold is higher than disk threshold,
  # set the peripheral zone speed to the cpu threshold
  new_peri_fan_speed=$found_cpu_threshold
else
  # If disk temp threshold is higher than cpu threshold,
  # set the peripheral zone speed to the disk threshold
  new_peri_fan_speed=$found_disk_threshold
fi
  
## APPLY THE FAN SPEEDS
if [[ $new_cpu_fan_speed == 1 ]]
then
  if [[ $new_cpu_fan_speed == 2 ]]
  then
    if [[ $new_cpu_fan_speed == 3 ]]
    then
      if [[ $new_cpu_fan_speed == 4 ]]
      then
        ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_cpus_crit
      else    
        ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_cpus_hot3
      fi
    else
      ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_cpus_hot2
    fi
  else
    ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_cpus_hot1
  fi
else
  ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_cpus_cool
fi
sleep 1
if [[ $new_peri_fan_speed == 1 ]]
then
  if [[ $new_peri_fan_speed == 2 ]]
  then
    if [[ $new_peri_fan_speed == 3 ]]
    then
      if [[ $new_peri_fan_speed == 4 ]]
      then
        ipmitool raw 0x30 0x70 0x66 0x01 0x01 $fan_peri_crit
      else    
        ipmitool raw 0x30 0x70 0x66 0x01 0x01 $fan_peri_hot3
      fi
    else
      ipmitool raw 0x30 0x70 0x66 0x01 0x01 $fan_peri_hot2
    fi
  else
    ipmitool raw 0x30 0x70 0x66 0x01 0x01 $fan_peri_hot1
  fi
else
  ipmitool raw 0x30 0x70 0x66 0x01 0x01 $fan_peri_cool 
fi
