#!/bin/bash
#https://www.domoticz.com/wiki/Bash_-_Speedtest.net_Download/Upload/Ping_monitoring
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online"
    a="Online| "
    b=`date`
    c="|"
#setup
host='localhost'
#idx for download, upload and ping
idxdl=1
idxul=2
idxpng=3
idxbb=4

# speedtest server number
# serverst=xxxx

# no need to edit
# speedtest-cli --simple --server $serverst > outst.txt
speedtest-cli --simple > speedtest.txt

download=$(cat speedtest.txt | sed -ne 's/^Download: \([0-9]*\.[0-9]*\).*/\1/p')
upload=$(cat speedtest.txt | sed -ne 's/^Upload: \([0-9]*\.[0-9]*\).*/\1/p')
png=$(cat speedtest.txt | sed -ne 's/^Ping: \([0-9]*\.[0-9]*\).*/\1/p')

# output if you run it manually
echo "Download = $download Mbps "
echo "Upload =  $upload Mbps "
echo "Ping =  $png ms "

# Updating download, upload and ping ..
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxdl&svalue=$download" >/dev/null 2>&1
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxul&svalue=$upload" >/dev/null 2>&1
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxpng&svalue=$png" >/dev/null 2>&1

# Reset Broadband switch
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxbb&svalue=0" >/dev/null 2>&1

# Domoticz logging
wget -q --delete-after "http://$host/json.htm?type=command&param=addlogmessage&message=speedtest.net-logging" >/dev/null 2>&1

# Write the speeds and timestamps in the text file    
   echo "$a$b$c$download$c$upload$c$png" >> /home/om/scripts/logs/date_time.txt
 if [ $download -le 20 ]; then  
  mail -s "Internet speed" ommacmini@gmail.com <<< "$a$b$c$download$c$upload$c$png" 
  fi
else
    a= "Offline :"
    b=`date`
    echo "$a$b" >> /home/om/scripts/logs/date_time.txt
fi
