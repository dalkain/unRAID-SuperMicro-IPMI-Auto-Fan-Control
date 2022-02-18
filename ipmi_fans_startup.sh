#!/bin/bash
#clearLog=true
#noParity=false

# Startup companion script for ipmi_fans_auto.sh
#
# This separate script must run on startup and sets the fan speed mode to "Full Speed Mode"
# Add this to "User Scripts" and set to run 'At Startup of Array'
#
####################
# VERY IMPORTANT: SuperMicro boards -REQUIRE- the fan mode be set to "Full Speed Mode"
# for ipmitool to be able to control fan speeds. If you try to put the required commands 
# from this script at the beginning of ipmi_fans_auto.sh, then your fans will ramp to 
# max speed for a second every single time the script runs to check temperatures.
# That will cause a bunch of annoying sound level changes and prematurely wear out fans.
####################
#
# Set IPMI fan mode to "Full Speed Mode"
ipmitool raw 0x30 0x45 0x01 0x01
sleep 1
#
# Set both fan zones to 50% duty cycle to lower noise
# until the auto script runs to determine final fan speeds
#
# CPU Fan Zone duty cycle to 50% 
ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x32
sleep 1
# Peripheral Fan Zone duty cycle to 50%
ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x32
