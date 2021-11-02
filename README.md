# Unraid-SuperMicro-IPMI-Auto-Fan-Control
A dirty little bash script I made to automate control of the fan speeds for a SuperMicro board using ipmitool. 

This pair of scripts is designed for Unraid's "User Scripts" plugin, though I'm sure it can be easily adapted to other linux systems.

It started out as me having trouble getting tools designed to do this to work right and just being very tired of loud fans. I still wanted the fans to crank up when heavy processing was being done. I fleshed it out a bit and added in-line comment instructions on how to modify it to suit your own needs.

Very basic rundown:
- Gather all of the CPU temps, determine max of these
- Gather all of the HDD temps, determine max of these
- Set speeds of the fan zones based configurable temperature thresholds (5 speeds settings)
- Use cron to run the script every few minutes

I rarely write bash scripts, and I was far too lazy to figure out how to properly write a dynamic curve and all that jazz.

Feel free to modify it to suit your needs -- GPLv3