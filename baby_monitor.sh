#!/bin/bash
while true
    do
    if (( $(bc <<< " `curl -s -m 5  http://bedroom:8080/audio.wav |sox -t wav - -n stat -v 2>&1|tail -n1` < 5") == 1 ))
        then 
	curl -d "Baby is Crying - BR" "http://snapserver.xtlive.net:1337/message"
        mythutil --notification --message_text "Baby is Crying" --origin "Master Bed Room" --timeout 15 --bcastaddr 172.16.12.255
    fi
done
