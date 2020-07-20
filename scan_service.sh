#!/bin/bash

#global argument
#$1 ip address
#$2 ports

time_out=7
silent=0

#Scanner arguments
#$1 protocol used
#$2 ip address
scanner(){
	e1=""
	request=$(curl -ski $1://$2:$port -m $time_out )
	response_code=$?
	if [ "$request" == "" ]; then
		if [ $response_code -ne 0 ]; then
			if [ $silent -eq 0 ]; then
				if [ $response_code -eq 0 ]; then
					e1="Protocol not supported"
				elif [ $response_code -eq 7 ]; then
					e1="Failed to connect"
				elif [ $response_code -eq 28 ]; then
					e1="Time out ($time_out s)"
				elif [ $response_code -eq 35 ]; then
					e1="SSL certificate issue"
				elif [ $response_code -eq 52 ]; then
					e1="Nothing was returned from the server"
				elif [ $response_code -eq 56 ]; then
					e1="Failure with receiving network data."
				else
					e1="$request error code $response_code"
				fi
			fi
		fi
	fi
	request=$(echo $request | cut -f 1-3 -d ' ')
	if [ $silent -eq 0 ]; then
		echo "$1://$2:$port ----> $request $e1"
	elif [ $response_code -eq 0 ]; then
		echo "$1://$2:$port ----> $request $e1"
	fi
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "Test http(s) response for all ports given in argument"
	echo "use -s to show only positives responses"
	echo "Syntax : scan-service Target_ip Target_port"
	echo "Exemple : scan-service.sh 192.168.25.3 80,443,1025,185 -s"
	exit
fi

for arg; do
	if [ "$arg" == "-s" ]; then
		silent=1
	fi
done

for port in $(echo $2 | sed  "s/,/\n/g"); do
	scanner "http" $1 $port
	scanner "https" $1 $port

done
