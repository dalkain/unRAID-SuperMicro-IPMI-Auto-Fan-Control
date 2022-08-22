# **NO LONGER ACTIVELY MAINTAINED**
**This repository is being archived. As I am no longer running a SuperMicro server, I will not be making any further updates nor providing any troubleshooting assistance. Feel free to use/fork/modify/whatever as long as the GPLv3 license is followed.**

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
    - _NOTE: If do not want to restart your server/array after adding this script, you must also click the "Run Script" button on ipmi_fans_startup.sh one time to force the required fan modes_
- Add ipmi_fans_auto.sh to User Scripts
  - Edit parameters within the script (read script comments for instructions) to suit your needs
  - Set to run 'Custom' and define a cron schedule in the field to run regularly (e.g. `*/5 * * * *` for every 5 minutes)

Example of how User Scripts should look once scheduled:
![image](https://user-images.githubusercontent.com/34625175/174487053-fbc9afcd-d289-44c6-ae86-fcc3e336601d.png)


### Other Notes:
- The server I used these scripts with had an X10DRi-T4+ motherboard. I have decommissioned that server and I am no longer actively using these scripts.
- I've used/tested these up to unRAID v6.10.3. I do remember there being a minor (but breaking) change to the awk syntax when I upgraded to 6.10.x from 6.9.2.
- While this was designed for and only works out-of-the-box with unRAID I'm sure it can be adapted to other linux systems with a bit of knowhow. You'd need to update how the script retrieves the CPU/HDD temps for your linux flavor of choice, but the ipmitool portions should work fine.
