#!/bin/bash

# Get system architecture using "uname -a" command
# The "uname" command prints system information, and the "-a" option displays all available information including the system architecture.
arch=$(uname -a)

# Get the number of physical CPUs using "grep" and "wc" commands
# The "grep" command searches for lines containing the "physical id" string in the /proc/cpuinfo file. The "wc -l" 
# command counts the number of matching lines.
cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)  

# Get the number of virtual CPUs using "grep" and "wc" commands
# The "grep" command searches for lines containing the "processor" string in the /proc/cpuinfo file. 
# The "wc -l" command counts the number of matching lines.
cpuv=$(grep "processor" /proc/cpuinfo | wc -l)  

# Get total and used RAM using "free" and "awk" commands
# The "free --mega" command displays memory usage in megabytes. 
# The "awk" command filters the line containing "Mem:" and extracts the total memory value.
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
# The "awk" command filters the line containing "Mem:" and extracts the used memory value.
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
# The "awk" command calculates the percentage of used memory by dividing used memory by total memory and multiplying by 100.
ram_percent=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')  

# Get total and used disk space using "df" command with human-readable output and "tail" command
# The "df -h" command displays disk space usage in a human-readable format. The "--output=size" option specifies to output only the size column. 
# The "tail -1" command selects the last line, which represents the total disk space.
disk_total=$(df -h --output=size --total | tail -1) 
disk_use=$(df -h --output=used --total | tail -1)  
disk_percent=$(df -h --output=pcent --total | tail -1 | tr -d '[:space:]')

# Get CPU load using "vmstat", "tail", and "awk" commands
# The "vmstat 1 2" command displays system-wide statistics including CPU usage. The "tail -1" command selects the last line, which represents the average CPU load. 
# The "awk" command extracts the 15th field, which represents the CPU idle percentage.
cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')  
# The "expr" command performs arithmetic calculations. Here, it subtracts the CPU idle percentage from 100 to get the CPU load percentage.
cpu_op=$(expr 100 - $cpul)
# The "printf" command formats the CPU load percentage to one decimal place.
cpu_fin=$(printf "%.1f" $cpu_op)

# The "uptime -s" command displays the system's uptime start time.
lb=$(uptime -s)  

# Check if LVM is in use by checking the "TYPE" column in "lsblk" output
if [ $(lsblk --noheadings --output=TYPE | grep -c 'lvm') -gt 0 ]; then
    lvmu="yes"
else
    lvmu="no"
fi

# Get the number of established TCP connections using "ss" command
# The "ss -t -a --numeric" command displays TCP connections in numeric format. 
# The "grep -c ESTAB" command counts the number of lines containing "ESTAB" which represents established connections.
tcpc=$(ss -t -a --numeric | grep -c ESTAB)  

# The "who" command lists logged-in users, and the "wc -l" command counts the number of lines.
ulog=$(who | wc -l)  

# Get network information using "hostname -I" and "ip link show" commands
# The "hostname -I" command displays the system's IP address.
ip=$(hostname -I)
# The "ip link show" command displays network interface information. The "awk" command filters the line containing "ether" keyword and extracts the MAC address.
mac=$(ip link show | awk '/ether/ {print $2}')

# Get the number of sudo commands executed using "journalctl" command
# The "journalctl _COMM=sudo" command filters the sudo commands in the system log. 
# The "grep COMMAND" command filters the lines containing the "COMMAND" string. The "wc -l" command counts the number of matching lines.
cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)  

# Format and display the system information using wall
wall "
    System Information:
    -------------------
    Architecture: $arch
    Physical CPUs: $cpuf
    Virtual CPUs: $cpuv
    Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
    Disk Usage: $disk_use/${disk_total} ($disk_percent%)
    CPU Load: $cpu_fin%
    Last Boot: $lb
    LVM Use: $lvmu
    TCP Connections: $tcpc ESTABLISHED
    Logged-in Users: $ulog
    Network: IP $ip ($mac)
    Sudo Commands: $cmnd executed"
