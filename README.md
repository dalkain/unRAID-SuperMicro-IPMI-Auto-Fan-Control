# unRAID SuperMicro IPMI Auto Fan Control

A pair of dirty little bash scripts to automate control of the fan speeds for a SuperMicro board using ipmitool. 

This pair of scripts is specifically designed for unRAID's "User Scripts" plugin, though I'm sure it can be adapted to other linux systems with a bit of knowhow. You'd most likely just need to detemrine the best way to retrieve the CPU/HDD temps for your linux flavor of choice, but the ipmitool portions should carry over

It started out quite awhile ago with me having trouble getting plugins/tools designed to do this to work right and just being very tired of loud fans (especially since my server is in my home office). I still wanted the fans to crank up some when heavy processing was being done, though I certainly don't need anywhere near the full throughput of those stock supermicro fans or the Dynatron CPU coolers I have installed. It's evolved over time and I've added in-line comment instructions on how to modify it to suit your own needs.

Very basic rundown of what this does:
- Gather all of the CPU package temps, determine max
- Gather all of the drive temps, determine max
- Set speeds of the fan zones based configurable temperature thresholds (5 speed settings per fan zone)
- Use cron to run the script every few minutes

Full disclosure: I very rarely write bash scripts, but this gets the job done. Feel free to modify it to suit your needs!

I'm currently using these on 6.10.0-rc4. I do remember there being a minor (but breaking) change to the awk syntax when I upgraded from 6.9.2.
