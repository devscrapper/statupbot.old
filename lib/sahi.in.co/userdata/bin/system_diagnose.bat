@echo off
wmic cpu get loadpercentage /VALUE /FORMAT:VALUE
wmic os get freephysicalmemory /VALUE /FORMAT:VALUE
wmic computersystem get TotalPhysicalMemory /VALUE /FORMAT:VALUE