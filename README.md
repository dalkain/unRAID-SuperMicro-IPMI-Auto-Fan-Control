# Unraid SuperMicro IPMI Auto Fan Control
A dirty little bash script I made to automate control of the fan speeds for a SuperMicro board using ipmitool. 

This pair of scripts is specifically designed for Unraid's "User Scripts" plugin, though I'm sure it can be easily adapted to other linux systems. You'd most likely just need to detemrine the best way to retrieve the CPU/HDD temps for your linux flavor of choice.

It started out as me having trouble getting tools designed to do this to work right and just being very tired of loud fans (especially since my server is in my home office). I still wanted the fans to crank up some when heavy processing was being done. I fleshed it out a bit and added in-line comment instructions on how to modify it to suit your own needs.

Very basic rundown:
- Gather all of the CPU temps, determine max
- Gather all of the HDD temps, determine max
- Set speeds of the fan zones based configurable temperature thresholds (5 speed settings per fan zone)
- Use cron to run the script every few minutes

NOTE: These checks will be considered drive activity and cause your drives to spin up or stay spinning! 
If you have your drives set to spin down automatically in Unraid, I highly recommend disabling all of the HDD temps and just basing this off of your CPU temps.

Full disclosure: I very rarely write bash scripts, and this is very elementary. Feel free to modify it to suit your needs though!
