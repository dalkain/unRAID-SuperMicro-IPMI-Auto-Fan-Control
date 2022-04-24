# unRAID SuperMicro IPMI Auto Fan Control
A pair of dirty little bash scripts to automate control of the fan speeds for a SuperMicro board using ipmitool. 

## What does it do?
- Gather all of the CPU package temps, determine max
- Gather all of the drive temps, determine max
- Set speeds of the fan zones based configurable temperature thresholds (5 speed settings per fan zone)

## Why?
It started out quite awhile ago with me having trouble getting plugins/tools designed to do this to work right and just being very tired of loud fans (especially since my server is in my home office). I still wanted the fans to crank up some when heavy processing was being done, though I certainly don't need anywhere near the full throughput of those stock supermicro fans or the Dynatron CPU coolers I have installed. It's evolved over time and I've added in-line comment instructions on how to modify it to suit your own needs.

## How to run:
This pair of scripts is specifically designed for unRAID's 'User Scripts' plugin. 
- Install the **User Scripts** plugin
- Install **ipmitool** (can be installed via the NerdPack GUI plugin)
- Add impi_fans_startup.sh to User Scripts
  - Set to run 'At Startup of Array'
- Add ipmi_fans_auto.sh to User Scripts
  - Edit parameters within the script (read script comments for instructions) to suit your needs
  - Set to run 'Custom' and define a cron schedule in the field to run regularly (e.g. `*/5 * * * *` for every 5 minutes)

### Other Notes:
- I'm currently using these on 6.10.0-rc4. I do remember there being a minor (but breaking) change to the awk syntax when I upgraded from 6.9.2.
- While this was designed for and only works out-of-the-box with unRAID I'm sure it can be adapted to other linux systems with a bit of knowhow. You'd need to update how the script retrieves the CPU/HDD temps for your linux flavor of choice, but the ipmitool portions should work fine.
