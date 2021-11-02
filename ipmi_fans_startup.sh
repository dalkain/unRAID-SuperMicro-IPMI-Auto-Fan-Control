###########################
## STARTUP COMPANION SCRIPT
## Copy this commented portion into its own **SEPARATE** script that runs on startup.
## (Unraid users: Use "User Scripts" and set to run on array startup)
## This will ensure the IPMI fan mode is always on the required "Full Speed" mode, which
## is a requirement to manually adjust fan speeds via ipmitool for SuperMicro IPMI
##
## Set IPMI fan mode to "full"
ipmitool raw 0x30 0x45 0x01 0x01
sleep 1
## final value below is duty cycle (0x00-0x64)
## CPU Zone duty cycle to 50%
ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x32
sleep 1
## Peripheral Zone duty cycle to 50%
ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x32
###########################
